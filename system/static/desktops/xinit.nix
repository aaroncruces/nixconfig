# to use xinitrc (sddm needs to be disabled)
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
  ];
  ##THE CONFIG FILES AND XINITRC IS MANAGED BY STOW+GIT
  services.xserver = {
       enable = true;
      #  windowManager.i3 = {
      #    enable = true;
      #    package = pkgs.i3;
      #  };
       videoDrivers = [ "modesetting" ]; # Let NixOS auto-detect the driver
       exportConfiguration = true; # Optional: Ensures X config files are generated
  };
}