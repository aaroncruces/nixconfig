{ config, lib, pkgs, ... }:

{
  # Autologin on tty1
  services.getty.autologinUser = "aaron";
}
