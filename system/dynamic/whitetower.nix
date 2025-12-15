{ config, lib, pkgs, ... }:

{
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
