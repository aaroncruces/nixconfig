{ config, lib, pkgs, ... }:

{
  # Required for i3wm (X11-based)
  services.xserver.enable = true;  
  ##THE CONFIG FILES AND XINITRC IS MANAGED BY STOW+GIT
  services.xserver = {
    videoDrivers = [ "modesetting" ]; # Let NixOS auto-detect the driver
    exportConfiguration = true; # Optional: Ensures X config files are generated
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [  # Optional but recommended for a usable i3 setup
        dmenu      # Application launcher
        polybar
        picom
        xorg.xrandr
      ];
    };
  };
}