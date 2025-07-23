{ config, lib, pkgs, ... }:

{
  imports = [
    ./desktops/i3.nix
    ./desktops/hyprland.nix
  ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "breeze";  # Reliable Qt-based theme
    settings = {
      Theme = {
        CursorTheme = "breeze_cursors";  # Explicit cursor theme
      };
    };
  };

  # Install SDDM dependencies and cursor theme
  environment.systemPackages = with pkgs; [
    qt5.qtquickcontrols2
    qt5.qtgraphicaleffects
    breeze-qt5  # Breeze theme and cursors
    adwaita-icon-theme  # Fallback cursor theme
  ];

  # Set system-wide cursor for X11/Wayland
  environment.variables = {
    XCURSOR_THEME = "breeze_cursors";
    XCURSOR_SIZE = "24";
  };
}