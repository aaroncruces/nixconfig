{ config, pkgs, ... }:
{
  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.xpadneo.enable = true; # Enables the advanced driver for Xbox Bluetooth controllers (blacklists the old xpad)
  hardware.bluetooth.package = pkgs.bluez5-experimental; # Optional: Use experimental BlueZ for better controller support
  hardware.bluetooth.settings = {
    General = {
      Privacy = "device"; # Helps with stable pairing
      JustWorksRepairing = "always";
      Class = "0x000100";
      FastConnectable = true;
      Experimental = true; # Enables features for gamepads
      ControllerMode = "dual"; # Supports BR/EDR and LE for Xbox controllers
      #ControllerMode = "bredr";  # Ensures BR/EDR mode for controllers
    };
    Input = {
      ClassicBondedOnly = false; # Allows HID input from non-bonded devices, fixes many "connected but no input" issues
    };
  };
  hardware.uinput.enable = true; # For Steam input and uaccess
  # Load kernel modules for Xbox controllers (remove xpad to avoid conflict with xpadneo)
  boot.kernelModules = [ "joydev" "uinput" ];
  # Bluetooth tweak for Xbox controller stability
  boot.extraModprobeConfig = ''
    options bluetooth disable_ertm=Y
  '';
  # Add tools for debugging
  environment.systemPackages = with pkgs; [
    bluez # For bluetoothctl
    evtest # For raw input events
    jstest-gtk
    blueman
  ];
  # Enable Blueman service for easier management/GUI pairing
  services.blueman.enable = true;
  # Optional: Ensure all firmware is available (helps with some BT adapters)
  hardware.enableAllFirmware = true;
}