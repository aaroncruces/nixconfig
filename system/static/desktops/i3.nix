{ config, lib, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver = {
    videoDrivers = lib.mkIf (builtins.pathExists /sys/module/nvidia) [ "nvidia" ] [ "modesetting" ];
    exportConfiguration = true;
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        polybar
        picom
        xorg.xrandr
      ];
    };
  };

  # NVIDIA settings
  hardware.nvidia = {
    enable = lib.mkIf (builtins.pathExists /sys/module/nvidia) true;
    modesetting.enable = true;  # For Wayland
    powerManagement.enable = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;  # Or .beta
  };

  # GPU acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # VirtualBox guest additions (for Oracle VM)
  virtualisation.virtualbox.guest.enable = lib.mkIf (!(builtins.pathExists /sys/module/nvidia)) true;
  virtualisation.virtualbox.guest.x11 = true;
}