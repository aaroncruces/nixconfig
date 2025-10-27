{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.networking.hostName == "whitetower") {
    # Mount NTFS partition at /winfs
    fileSystems."/winfs" = lib.mkForce {
      device = "/dev/disk/by-uuid/7AB85F10B85ECA71";
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

    # Mount NTFS partition at /winfs
    fileSystems."/winefi" = lib.mkForce {
      device = "/dev/disk/by-uuid/EAB0-361A";
      fsType = "vfat";
      options = [ "defaults" "nofail" ]; # User-readable, aaron access
    };

    ## FUSE kernel module
    boot.kernelModules = [ "fuse" ];

    # FUSE userspace config
    programs.fuse.userAllowOther = true;

    # Install SSHFS
    environment.systemPackages = with pkgs; [ fuse3 sshfs sshfs-fuse ];

    # # Create mount point
    # systemd.tmpfiles.rules = [
    #   "d /redtower 0755 root root - -"
    # ];

    # # SSHFS mount
    # fileSystems."/redtower" = {
    #   device =
    #     "aaron@192.168.2.10:/"; # Remote root; adjust to /raidpool if needed
    #   fsType = "sshfs";
    #   options = [
    #     "defaults"
    #     "_netdev" # Wait for network
    #     "allow_other" # Non-root access (Docker/Jellyfin)
    #     "noauto" # Don't mount at boot
    #     "x-systemd.automount" # Mount on access
    #     "x-systemd.device-timeout=30" # Allow 30s for network/SSH
    #     "IdentityFile=/root/.ssh/id_ed25519_nopass"
    #     "Port=1810"
    #     "uid=1000"
    #     "gid=100"
    #     "reconnect"
    #     "ServerAliveInterval=15"
    #     # Removed "debug" to avoid potential issues; re-add if needed
    #   ];
    # };

    boot.loader.grub.extraEntries = ''
      menuentry "Windows" {
        insmod part_gpt
        insmod fat
        insmod chain
        search --no-floppy --fs-uuid --set=root EAB0-361A
        chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      }
    '';

    services.openssh.ports = [ 1812 ];
    # ------------------------------------------------------
    # # Disable global DHCP to manage interfaces manually
    # networking.useDHCP = false;

    # # Configure the physical interface without DHCP or IP
    # networking.interfaces.enp4s0.useDHCP = false;

    # # Define the bridge interface br0 and attach enp4s0 to it
    # networking.bridges = {
    #   br0 = {
    #     interfaces = [ "enp4s0" ];
    #   };
    # };

    # # Configure br0 with a static IP address
    # networking.interfaces.br0.ipv4.addresses = [{
    #   address = "192.168.1.12";
    #   prefixLength = 24; # Equivalent to subnet mask 255.255.255.0
    # }];

    # # Set default gateway (adjust as needed for your network)
    # networking.defaultGateway = {
    #   address = "192.168.1.1";
    #   interface = "br0";
    # };

    # # Set DNS servers (adjust as needed)
    # networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

    # ------------------------------------------------------
    # networking.networkmanager = {
    #   enable = true;
    #   ensureProfiles = {
    #     profiles = {
    #       "static-ip-ethernet" = {
    #         connection = {
    #           id = "Static IP Ethernet";
    #           type = "ethernet";
    #           interface-name = "enp4s0"; # Adjust if needed (e.g., wlan0 for Wi-Fi)
    #           autoconnect = true;
    #         };
    #         ipv4 = {
    #           method = "manual";
    #           address = "192.168.1.12/24"; # Static IP and subnet mask
    #           gateway = "192.168.1.1"; # Gateway IP
    #           dns = "1.1.1.1;8.8.8.8"; # DNS servers (Cloudflare and Google)
    #         };
    #         ipv6 = {
    #           method = "disabled"; # Disable IPv6
    #         };
    #       };
    #     };
    #   };
    # };
    # ------------------------------------------------------
    # Enable NetworkManager
    networking.networkmanager.enable = true;

    # Disable the default networking configuration to avoid conflicts
    networking.useDHCP = false;
    networking.interfaces.enp4s0.useDHCP = false;

    # Ensure NetworkManager manages all interfaces
    networking.networkmanager.unmanaged = [ ];

    # Configure NetworkManager connection profiles for the bridge
    networking.networkmanager.ensureProfiles.profiles = {
      bridge-br0 = {
        connection = {
          id = "bridge-br0";
          type = "bridge";
          interface-name = "br0";
          autoconnect = true;
        };
        ipv4 = { method = "auto"; };
        bridge = {
          stp =
            false; # Disable Spanning Tree Protocol (optional, enable if needed)
          ageing-time = 300;
        };
      };
      bridge-slave-enp4s0 = {
        connection = {
          id = "bridge-slave-enp4s0";
          type = "ethernet";
          interface-name = "enp4s0";
          master = "br0";
          slave-type = "bridge";
          autoconnect = true;
        };
      };
    };

  };
}
