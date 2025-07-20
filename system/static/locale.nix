{ config, lib, pkgs, ... }:

{
  services.xserver.xkb.layout = "es";
  console.keyMap = "es";
}