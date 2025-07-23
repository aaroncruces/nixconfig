{ config, lib, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;  # Installs Hyprland and sets up Wayland session files
    xwayland.enable = true;  # Enables XWayland for running X11 apps in Hyprland
  };
}