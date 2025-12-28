{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./system/static/locale.nix
    ./system/static/desktop.nix
    
    ./system/static/ssh.nix
    ./system/static/bootloader.nix
    ./system/static/audio.nix
    ./system/static/adb.nix
    ./system/static/dotnet.nix
    ./system/static/fonts.nix
    ./system/static/vm.nix
    ./system/static/wireshark.nix
    ./system/static/packages.nix
    ./system/static/autologin.nix
    

    ./system/static/bluetooth.nix

    # check manually
    ./system/static/nvidia.nix
    ./system/dynamic/partitions.nix
    ./system/dynamic/hostname.nix

    # depends on the hostname, so needs to be executed on a second pass once booted
    ./system/dynamic/whitetower.nix
    ./system/dynamic/nixdev.nix

    ./user/users.nix
    ./user/services.nix
    ./user/homemanager.nix
  ];
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05"; # Keep 25.05 for state compatibility
}
