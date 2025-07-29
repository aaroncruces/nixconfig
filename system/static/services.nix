{ config, lib, pkgs, ... }:

{
  services.openssh = {
  enable = true;
    settings = {
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
      PasswordAuthentication = false;
      PermitEmptyPasswords = false;
      X11Forwarding = true;
      X11UseLocalhost = true;
      MaxStartups = "10:30:100";
    };
  };
  system.copySystemConfiguration = true;
}