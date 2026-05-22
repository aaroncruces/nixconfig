{ config, lib, pkgs, ... }:

let
  # Hyprland v0.55.2, pinned independently of the system nixpkgs channel.
  pinnedHyprland = builtins.getFlake "github:hyprwm/Hyprland/v0.55.2";

  hyprlandPackages = pinnedHyprland.packages.${pkgs.stdenv.hostPlatform.system};
  hyprlandPortalPackage = hyprlandPackages.xdg-desktop-portal-hyprland;
in
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = hyprlandPackages.hyprland;
    portalPackage = hyprlandPortalPackage;
  };

  environment.systemPackages = with pkgs; [
    wayland
    xwayland
    waybar
    hyprcursor
    libdrm
    mesa
    wayland-protocols
    hyprlandPortalPackage
    wlroots
    wofi
    hyprpolkitagent
    hyprls
  ];

  environment.pathsToLink = [ "/share/hypr" ];
  
}
