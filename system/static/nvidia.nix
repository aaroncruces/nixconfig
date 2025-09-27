{ config, pkgs, ... }:

let
  nvidiaPatchSrc = builtins.fetchGit {
    url = "https://github.com/icewind1991/nvidia-patch-nixos.git";
    # Optional: rev = "your-commit-hash";  # Pin for reproducibility
  };
in

{
  nixpkgs.overlays = [
    (import "${nvidiaPatchSrc}/overlay.nix")
  ];

  nixpkgs.config.allowUnfree = true;

  # NVIDIA driver setup
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    exportConfiguration = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = false;  # Adjust if using GNOME
  };

  hardware = {
    # OpenGL support (for 24.05+; use graphics.enable in unstable)

    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      nvidiaSettings = true;
      open = true;  # Set false for proprietary if open modules fail
      package = pkgs.nvidia-patch.patch-nvenc (pkgs.nvidia-patch.patch-fbc config.boot.kernelPackages.nvidiaPackages.stable);
    };

    # NVIDIA Container Toolkit (CDI mode; no mounts needed)
    nvidia-container-toolkit = {
      enable = true;
      package = pkgs.nvidia-container-toolkit;
      # Removed mounts: Defaults handle nvidia-smi and devices
    };
  };

  # Docker integration
  virtualisation.docker = {
    enable = true;
    extraOptions = "--add-runtime nvidia=/run/current-system/sw/bin/nvidia-container-runtime";
  };

  # System packages
  environment.systemPackages = with pkgs; [
    (ffmpeg-full.override {
      withUnfree = true;
      withNvenc = true;
      withNpp = true;
      withCuda = true;
      withNvdec = true;
      withX265 = true;
      withCuvid = true;
    })
    nvtopPackages.full
    gpustat
    nvidia-container-toolkit  # For manual CDI tools
  ];

  # User groups
  users.users.aaron.extraGroups = [ "video" "docker" ];
}