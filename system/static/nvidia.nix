{ config, pkgs, ... }:

{
  # Enable the X11 windowing system and Hyprland
  services.xserver = {
    enable = true;
    exportConfiguration = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = false; # Optional: disable GNOME if not needed
  };

  # NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];


  # Ensure OpenGL is enabled for NVIDIA
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # NVIDIA hardware configuration
  hardware.nvidia = {
    modesetting.enable = true; # Required for Wayland
    powerManagement.enable = false; # May cause issues with some setups, adjust as needed
    package = config.boot.kernelPackages.nvidiaPackages.stable; # Use stable NVIDIA drivers
  };

  # GPU acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };


  ########## NVIDIA ##########
  programs.hyprland.nvidiaPatches = true; # Enable NVIDIA-specific patches

}