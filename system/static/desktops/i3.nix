{ config, lib, pkgs, ... }:

{
  # Enable X server for i3
  services.xserver.enable = true;

  # Install i3, polybar, and dmenu
  environment.systemPackages = with pkgs; [
    i3
    polybar
    dmenu
  ];
}