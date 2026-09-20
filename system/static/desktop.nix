{ config, lib, pkgs, ... }:

{
  imports = [ ./desktops/i3.nix ./desktops/hyprland.nix ./desktops/gnome.nix ];

  services.gnome.gnome-keyring.enable = false;
  services.gnome.gcr-ssh-agent.enable = false;
  programs.ssh.startAgent = false;
  
}
