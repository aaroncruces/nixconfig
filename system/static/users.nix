{ config, lib, pkgs, ... }:

{
  users.users.aaron = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # sudo and NetworkManager access
    initialPassword = "changeme"; # Change after install
    initialFiles.".profile".text = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec startx
      fi
    '';
  };
}