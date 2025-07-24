{ config, pkgs, ... }:

{
  # Enable the X11 windowing system and Hyprland
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    exportConfiguration = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = false; # Optional: disable GNOME if not needed
  };

  hardware = {
    opengl.enable =  true;
    nvidia = {
      modesetting.enable = true; # Required for Wayland
      powerManagement.enable = false; # May cause issues with some setups, adjust as needed
      package = config.boot.kernelPackages.nvidiaPackages.stable; # Use stable NVIDIA drivers
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
  
  environment.systemPackages = with pkgs; [
    (ffmpeg.override { withNvenc = true; }) # Enable NVENC for FFmpeg
  ];

}