{ config, lib, pkgs, ... }:

let
  # Import the same reusable bridge/address-cascade builder used by nixdev.
  networkmanagerBridgeAddressCascade =
    import ../lib/networkmanager-bridge-address-cascade.nix {
      inherit lib pkgs;
    };

  # Build whitetower's NetworkManager bridge configuration. DHCP is tried first;
  # once the DHCP server identifies the LAN, the dispatcher swaps in the stable
  # preferred address for known networks.
  whitetowerBridgeAddressCascade =
    networkmanagerBridgeAddressCascade.mkBridgeDhcpAddressCascade {
      # Name of the Linux bridge interface exposed to the rest of the system.
      bridgeInterface = "br0";

      # Physical NIC that NetworkManager enslaves into the bridge.
      ethernetInterface = "enp4s0";

      # Declarative NetworkManager profile ID for the normal DHCP bridge.
      dhcpProfileId = "bridge-br0";

      # Declarative NetworkManager profile ID for the no-DHCP fallback bridge.
      noDhcpFallbackProfileId = "bridge-br0-static-fallback";

      # Static IPv4 address used when the fallback profile is activated.
      noDhcpFallbackAddress = "192.168.1.12";

      # Preferred stable host addresses for LANs identified by their DHCP server.
      # Unknown DHCP servers keep the ordinary DHCP lease.
      dhcpServerAddressRules = [
        {
          # 192.168.0.x LAN.
          dhcpServerAddress = "192.168.0.1";
          preferredHostAddress = "192.168.0.12";
        }
        {
          # 192.168.1.x LAN.
          dhcpServerAddress = "192.168.1.1";
          preferredHostAddress = "192.168.1.12";
        }
        {
          # 192.168.2.x LAN.
          dhcpServerAddress = "192.168.2.1";
          preferredHostAddress = "192.168.2.12";
        }
      ];
    };
in {
  config = lib.mkIf (config.networking.hostName == "whitetower") {
    # Mount NTFS partition at /winfs
    fileSystems."/winfs" = lib.mkForce {
      device = "/dev/disk/by-uuid/3E28357F283536ED";
      fsType = "ntfs";
      options = [
        "defaults"
        "nofail"
        "uid=1000"
        "gid=100"
        "dmask=022"
        "fmask=133"
      ]; # User-readable, aaron access
    };

    # # Mount NTFS partition at /winfs
    # fileSystems."/winefi" = lib.mkForce {
    #   device = "/dev/disk/by-uuid/EAB0-361A";
    #   fsType = "vfat";
    #   options = [ "defaults" "nofail" ]; # User-readable, aaron access
    # };

    ## FUSE kernel module
    boot.kernelModules = [ "fuse" ];

    # Enable iGPU passthrough for VMs on whitetower.
    boot.kernelParams =
      [ "amd_iommu=on" "iommu=pt" "vfio-pci.ids=1002:15dd,1002:15de" ];

    boot.initrd.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];

    boot.blacklistedKernelModules = [ "amdgpu" "radeon" ];

    boot.extraModprobeConfig = ''
      options vfio-pci ids=1002:15dd,1002:15de
      softdep amdgpu pre: vfio-pci
    '';

    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    # FUSE userspace config
    programs.fuse.userAllowOther = true;

    # Install SSHFS
    environment.systemPackages = with pkgs; [ fuse3 sshfs sshfs-fuse ];

    # boot.loader.grub.extraEntries = ''
    #   menuentry "Windows" {
    #     insmod part_gpt
    #     insmod fat
    #     insmod chain
    #     search --no-floppy --fs-uuid --set=root EAB0-361A
    #     chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    #   }
    # '';

    services.openssh.ports = [ 1812 ];

    # Enable SSHFS support
    boot.supportedFilesystems = [ "sshfs" ];

    fileSystems."/redtower" = {
      device = "aaron@192.168.1.10:/";
      fsType = "sshfs";
      options = [
        "allow_other"
        "default_permissions"
        "reconnect"
        "port=1810"
        "IdentityFile=/home/aaron/.ssh/id_ed25519_nopass"
        "_netdev"
        "x-systemd.automount"
        "noauto"
        "nofail"
      ];
    };

    # Enable NetworkManager as the only network configuration manager.
    networking.networkmanager.enable = true;

    # Disable NixOS' legacy DHCP path so it does not race NetworkManager.
    networking.useDHCP = false;

    # Prevent the physical NIC from being configured directly; it is a bridge
    # slave and gets connectivity through br0.
    networking.interfaces.enp4s0.useDHCP = false;

    # Keep the unmanaged list empty so NetworkManager can own br0 and enp4s0.
    networking.networkmanager.unmanaged = [ ];

    # Do not block boot on wired network detection or DHCP timeouts.
    systemd.services."NetworkManager-wait-online".enable = false;

    # Install the generated dispatcher hook into
    # /etc/NetworkManager/dispatcher.d. It runs after DHCP events on br0.
    networking.networkmanager.dispatcherScripts =
      [ whitetowerBridgeAddressCascade.dispatcherScript ];

    # Generated bridge, no-DHCP fallback, and bridge-slave profiles.
    networking.networkmanager.ensureProfiles.profiles =
      whitetowerBridgeAddressCascade.profiles;

  };
}
