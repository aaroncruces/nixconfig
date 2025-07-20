{ config, lib, pkgs, ... }:

{
  # Import the current window manager (i3)
  imports = [
    ./desktops/i3.nix
  ];
}