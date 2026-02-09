# autologin.nix
{ config, lib, pkgs, ... }:

{
  services.xserver.displayManager = {
    autoLogin = {
      enable = true;
      user = "aaron";
    };
    gdm = {
      enable = true; # Already enabled in your nvidia.nix, but reinforced here
      wayland = true; # Ensures Wayland support for Hyprland
    };
  };

  # Set default session to Hyprland (matches the session desktop file name from programs.hyprland)
  services.displayManager.defaultSession = "hyprland";
}