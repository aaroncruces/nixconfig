{ config, lib, pkgs, ... }:

{
  services.xserver.xkb.layout = "es";
  console.keyMap = "es";
  time.timeZone = "America/Santiago"; # Adjust to your timezone
}
