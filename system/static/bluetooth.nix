{ config, pkgs, ... }:

{
  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings = {
    General = {
      ControllerMode = "dual"; # Supports BR/EDR and LE for Xbox controllers
      Experimental = true;
      FastConnectable = true;
    };
  };

  # Load kernel modules for Xbox controllers
  boot.kernelModules = [ "xpad" "joydev" "uinput" ];

  # Bluetooth tweak for Xbox controller stability
  boot.extraModprobeConfig = ''
    options bluetooth disable_ertm=Y
  '';

  # Add tools for debugging
  environment.systemPackages = with pkgs; [
    bluez # For bluetoothctl
    evtest # For raw input events
    jstest-gtk
  ];

  # Grant user access to input devices
}
