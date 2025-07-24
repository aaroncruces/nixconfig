{ config, lib, pkgs, ... }:

{
  services.openssh = {
  enable = true;
    settings = {
      PermitRootLogin = "no";
      PubkeyAuthentication = "yes";
      AuthorizedKeysFile = [ ".ssh/authorized_keys" ];
      PasswordAuthentication = "no";
      PermitEmptyPasswords = "no";
      X11Forwarding = "yes";
      X11UseLocalhost = "yes";
      MaxStartups = "10:30:100";
    };
  };
  system.copySystemConfiguration = true;
}