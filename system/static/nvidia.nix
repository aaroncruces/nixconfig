{ config, pkgs, ... }:

let
  nvidiaPatchSrc = builtins.fetchGit {
    url = "https://github.com/icewind1991/nvidia-patch-nixos.git";
    # Optional: rev = "commit-hash"; # e.g., "abc123..." for pinning
  };
in

{
  nixpkgs.overlays = [
    (import "${nvidiaPatchSrc}/overlay.nix")
  ];

  # Your existing NVIDIA config module, imported here or defined inline
  # For example:
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    exportConfiguration = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = false; # Optional: disable GNOME if not needed
  };

  hardware = {
    nvidia = {
      modesetting.enable = true; # Required for Wayland
      powerManagement.enable = false; # May cause issues with some setups, adjust as needed
      # Apply the patches: NVENC first, then FBC (order matters as per repo example)
      package = pkgs.nvidia-patch.patch-nvenc (pkgs.nvidia-patch.patch-fbc config.boot.kernelPackages.nvidiaPackages.stable);
      open = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        virglrenderer  # For VirGL 3D acceleration in VMs
        nvidia-vaapi-driver  # NVIDIA VAAPI for hardware decoding (optional but useful)
        vaapiVdpau  # VDPAU backend for VAAPI (helps with video accel)
      ];
    };
  };



environment.systemPackages = with pkgs; [
  (ffmpeg-full.override {
    withUnfree = true;
    withNvenc = true;    # Keeps NVENC enabled
    withNpp = true;
    withCuda = true;
    withNvdec = true;
    withX265 = true;
    withCuvid = true;
  })
  nvtopPackages.full
  gpustat
  mesa-demos
  virtualgl
  virtualglLib
];
# added unstable channel with sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
}