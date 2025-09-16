{ config, lib, pkgs, ... }:

{
    config = lib.mkIf (config.networking.hostName == "whitetower") {
     # Mount NTFS partition at /winfs
     fileSystems."/winfs" = lib.mkForce {
       device = "/dev/disk/by-uuid/7AB85F10B85ECA71";
       fsType = "ntfs";
       options = [ "defaults" "nofail" "uid=1000" "gid=100" "dmask=022" "fmask=133" ]; # User-readable, aaron access
     };
    
      # Mount NTFS partition at /winfs
     fileSystems."/winefi" = lib.mkForce {
       device = "/dev/disk/by-uuid/EAB0-361A";
       fsType = "vfat";
       options = [ "defaults" "nofail"]; # User-readable, aaron access
     };
    
     boot.loader.grub.extraEntries = ''
       menuentry "Windows" {
         insmod part_gpt
         insmod fat
         insmod chain
         search --no-floppy --fs-uuid --set=root EAB0-361A
         chainloader /EFI/Microsoft/Boot/bootmgfw.efi
       }
     '';
    
    #  services.openssh.ports = [ 1812 ];
    
    #  networking.networkmanager = {
    #    enable = true;
    #    ensureProfiles = {
    #      profiles = {
    #        "static-ip-ethernet" = {
    #          connection = {
    #            id = "Static IP Ethernet";
    #            type = "ethernet";
    #            interface-name = "enp4s0"; # Adjust if needed (e.g., wlan0 for Wi-Fi)
    #            autoconnect = true;
    #          };
    #          ipv4 = {
    #            method = "manual";
    #            address = "192.168.1.10/24"; # Static IP and subnet mask
    #            gateway = "192.168.1.1"; # Gateway IP
    #            dns = "1.1.1.1;8.8.8.8"; # DNS servers (Cloudflare and Google)
    #          };
    #          ipv6 = {
    #            method = "disabled"; # Disable IPv6
    #          };
    #        };
    #      };
    #    };
    #  };
    };
}