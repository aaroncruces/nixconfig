{ config, lib, pkgs, ... }:

{
  imports = [
    ./desktops/i3.nix
    ./desktops/hyprland.nix
  ];

}