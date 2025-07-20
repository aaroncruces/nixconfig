{ config, lib, pkgs, ... }:

{
  services.openssh.enable = true;
  system.copySystemConfiguration = true;

  # Explicitly disable display managers
  services.displayManager.sddm.enable = false;
  services.xserver.displayManager.sddm.enable = false;
  services.xserver.displayManager.lightdm.enable = false;
  services.xserver.displayManager.gdm.enable = false;
}