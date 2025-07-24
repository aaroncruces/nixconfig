{ config, lib, pkgs, ... }:

{
  services.openssh.enable = true;
  system.copySystemConfiguration = true;
}