{ config, lib, pkgs, ... }:

{
  users.users.aaron = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # sudo and NetworkManager access
    initialPassword = "changeme"; # Change after install
    shell = pkgs.zsh;
  };

  # Ensure zsh is installed
  environment.systemPackages = with pkgs; [
    zsh
  ];
}