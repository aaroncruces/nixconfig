{ config, lib, pkgs, ... }:

{
  boot = {
    supportedFilesystems = [ "btrfs" "ntfs" ];
    initrd.kernelModules = [ "btrfs" ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = false;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
      };
    };
  };

  zramSwap.enable = true;
}
