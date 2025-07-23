{ config, lib, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    # Optional: NVIDIA patches for better Wayland support
    nvidiaPatches = lib.mkIf (builtins.pathExists /sys/module/nvidia) true;
  };

  # Ensure Wayland dependencies
  environment.systemPackages = with pkgs; [
    wayland
    xwayland
    libdrm
    mesa
  ];
}