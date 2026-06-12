{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    gnumake
    gcc
    pkg-config
    libusb1
    libusb-compat-0_1
    readline
    ncurses
    ppsspp
    gamescope
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="054c", ATTR{idProduct}=="01c9", TAG+="uaccess", MODE="0666"
  '';
}
