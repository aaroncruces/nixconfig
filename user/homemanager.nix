{ config, pkgs, lib, ... }:

{

  # Add home-manager to system packages
  environment.systemPackages = with pkgs; [
    home-manager
  ];

}