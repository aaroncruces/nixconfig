{ config, lib, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    nvidiaPatches = lib.mkIf (builtins.pathExists /sys/module/nvidia) true;
  };

  environment.systemPackages = with pkgs; [
    wayland
    xwayland
    libdrm
    mesa
    wayland-protocols
    wlroots
  ];
}