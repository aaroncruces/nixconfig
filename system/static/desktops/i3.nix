{ config, lib, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver = {
    videoDrivers = if (builtins.pathExists /sys/module/nvidia) then [ "nvidia" ] else [ "modesetting" ];
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

  # NVIDIA settings (requires nixpkgs.config.allowUnfree = true)
  hardware.nvidia = {
    modesetting.enable = lib.mkIf (builtins.pathExists /sys/module/nvidia) true;  # For Wayland (Hyprland/SDDM)
    powerManagement.enable = false;  # Adjust for laptop power saving
    package = config.boot.kernelPackages.nvidiaPackages.stable;  # Stable driver
    # package = config.boot.kernelPackages.nvidiaPackages.beta;  # Uncomment for newer GPUs
  };

  # GPU acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # VirtualBox guest additions (for Oracle VM)
  virtualisation.virtualbox.guest.enable = lib.mkIf (!(builtins.pathExists /sys/module/nvidia)) true;
}