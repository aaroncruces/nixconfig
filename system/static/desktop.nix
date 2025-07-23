{ config, lib, pkgs, ... }:

{
  # Import the current window manager (i3)
  imports = [
    ./desktops/i3.nix
    ./desktops/hyprland.nix
  ];
  
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;  # Enables Wayland session support in SDDM (for Hyprland)
  };
  # display managers
  # services.displayManager.sddm.enable = false;
  # services.xserver.displayManager.sddm.enable = false;
  # services.xserver.displayManager.lightdm.enable = false;
  # services.xserver.displayManager.gdm.enable = false;
}