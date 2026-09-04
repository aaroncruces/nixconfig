{ config, lib, pkgs, ... }: {

  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="2dc8", MODE="0666", TAG+="uaccess", TAG+="udev-acl"
    KERNEL=="hidraw*", KERNELS=="*2DC8:*", MODE="0666", TAG+="uaccess", TAG+="udev-acl"
  '';
  hardware.steam-hardware.enable = true;
  users.users.aaron.extraGroups = [ "input" ];
}
