{ config, lib, pkgs, ... }:

{
  # Install i3, polybar, and dmenu
  environment.systemPackages = with pkgs; [
    i3
    polybar
    dmenu
    picom
    xorg.xorgserver
    xorg.xinit
    xorg.xf86inputlibinput
    xorg.xrandr
    xorg.xset
    xorg.xsetroot
    xorg.xauth
    #xorg.xf86videointel # Replace with xorg.xf86videonvidia or xorg.xf86videoamdgpu if needed
  ];
}