{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./system/static/networking.nix
    ./system/static/locale.nix
    ./system/static/desktop.nix
    ./system/static/users.nix
    ./system/static/packages.nix
    ./system/static/services.nix
    ./system/static/bootloader.nix
    ./system/static/homemanager.nix

    ./system/dynamic/partitions.nix
  ];

  # System state version
  system.stateVersion = "25.05";
}