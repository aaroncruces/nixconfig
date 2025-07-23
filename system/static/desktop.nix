{ config, lib, pkgs, ... }:

{
  # Import the current window manager (i3)
  imports = [
    ./desktops/i3.nix
    ./desktops/hyprland.nix
  ];
  
  # for i3 and hyprland
  services.displayManager.sddm = {
    enable = true;
    # Enables Wayland session support in SDDM (for Hyprland)
    wayland.enable = true;  
  };
  # display managers
  # services.displayManager.sddm.enable = false;
  # services.xserver.displayManager.sddm.enable = false;
  # services.xserver.displayManager.lightdm.enable = false;
  # services.xserver.displayManager.gdm.enable = false;
}