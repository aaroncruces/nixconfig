{ config, lib, pkgs, ... }:

{
  services.xserver.xkb.layout = "es";
  console.keyMap = "es";
  networking.hostName = "whitetower"; # Set your hostname
  time.timeZone = "America/Santiago"; # Adjust to your timezone
}