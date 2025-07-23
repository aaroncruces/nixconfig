{ config, lib, pkgs, ... }:

{
  imports = [
    ./desktops/i3.nix
    ./desktops/hyprland.nix
  ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;  # For Hyprland
    theme = "breeze";
    settings = {
      Theme = {
        CursorTheme = "breeze_cursors";  # Fix missing cursor
      };
    };
  };

  environment.systemPackages = with pkgs; [
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.breeze-qt5  # Qt 5 Breeze theme and cursors
    adwaita-icon-theme  # Fallback cursor
    hyprcursor  # For Hyprland cursor
    waybar  # For Hyprland bar
  ];

  environment.variables = {
    XCURSOR_THEME = "breeze_cursors";
    XCURSOR_SIZE = "24";
  };
}