{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./system/static/networking.nix
    ./system/static/locale.nix
    ./system/static/desktop.nix
    ./system/static/packages.nix
    ./system/static/services.nix
    ./system/static/bootloader.nix
    ./system/static/audio.nix

    # check manually
    ./system/static/nvidia.nix
    ./system/dynamic/partitions.nix

    ./system/dynamic/whitetower.nix

    ./user/users.nix
    ./user/services.nix
    ./user/homemanager.nix
  ];

  # System state version
  system.stateVersion = "25.05";
}