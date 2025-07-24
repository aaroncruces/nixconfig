{ config, lib, pkgs, ... }:

{
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      dmenu
      polybar
      picom
      xorg.xrandr
    ];
  };

}