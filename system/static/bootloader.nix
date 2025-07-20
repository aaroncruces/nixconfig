{ config, lib, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;
  boot.supportedFilesystems = [ "btrfs" ];
  boot.initrd.kernelModules = [ "btrfs" ];
  zramSwap.enable = true;
}