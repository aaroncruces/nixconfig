{ config, lib, pkgs, ... }:

{
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

  # Ensure ntfs support
  environment.systemPackages = with pkgs; [
    ntfs3g
  ];

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
    
}