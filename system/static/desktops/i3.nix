{ config, lib, pkgs, ... }:

{
  # Install i3, polybar, and dmenu
  environment.systemPackages = with pkgs; [
    i3
    polybar
    dmenu
    picom
    (xorg // { recurseForDerivations = true; })
  ];
}