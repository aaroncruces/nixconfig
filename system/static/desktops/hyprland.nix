{ config, lib, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    wayland
    xwayland
    waybar
    hyprcursor
    libdrm
    mesa
    wayland-protocols
    xdg-desktop-portal-hyprland
    wlroots
    wofi
    hyprpolkitagent
  ];
}