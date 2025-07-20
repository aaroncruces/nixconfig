{ config, lib, pkgs, ... }:

{
  services.openssh.enable = true;
  system.copySystemConfiguration = true;

  # Autologin on tty1
  services.getty.autologinUser = "aaron";

  # Explicitly disable display managers
  services.displayManager.sddm.enable = false;
  services.displayManager.lightdm.enable = false;
}