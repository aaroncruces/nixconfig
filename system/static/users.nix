{ config, lib, pkgs, ... }:

{
  users.users.aaron = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # sudo and NetworkManager access
    initialPassword = "changeme"; # Change after install
    shell = pkgs.zsh;
  };

  # Enable zsh for proper shell integration
  programs.zsh.enable = true;

  # Ensure zsh is installed
  environment.systemPackages = with pkgs; [
    zsh
  ];
  nix.settings.allowed-users = [ "@wheel" ];
}