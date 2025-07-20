{ config, lib, pkgs, ... }:

{
  services.openssh.enable = true;
  system.copySystemConfiguration = true;

  # Autologin on tty1 and directly start i3
  services.getty.autologinUser = "aaron";

  # Explicitly disable display managers
  services.displayManager.sddm.enable = false;
  services.displayManager.lightdm.enable = false;
  services.displayManager.gdm.enable = false;
}