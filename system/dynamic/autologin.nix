{ config, lib, pkgs, ... }:

{
  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "aaron";
    };
    defaultSession = "hyprland";
  };
}
