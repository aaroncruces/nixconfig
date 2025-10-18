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
      Privacy = "device";  # Helps with stable pairing
      JustWorksRepairing = "always";
      Class = "0x000100";
      #ControllerMode = "bredr";  # Ensures BR/EDR mode for controllers
    };
  };
  hardware.firmware = [ pkgs.linux-firmware ];

#  hardware.xpadneo.enable = true;
#  hardware.uinput.enable = true;  # For Steam input and uaccess
  # Load kernel modules for Xbox controllers
  boot.kernelModules = [ "xpad" "joydev" "uinput" ];

  # Bluetooth tweak for Xbox controller stability
  boot = {
#    extraModulePackages = with config.boot.kernelPackages; [ xpadneo ];
    extraModprobeConfig = ''
      options bluetooth disable_ertm=Y  # Improves Bluetooth reliability for controllers
    '';
  };

  # Add tools for debugging
  environment.systemPackages = with pkgs; [
    bluez # For bluetoothctl
    evtest # For raw input events
    jstest-gtk
    blueman
  ];

  # Grant user access to input devices
}
