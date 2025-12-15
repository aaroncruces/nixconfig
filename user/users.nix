{ config, lib, pkgs, ... }:

{
  users.groups.wireshark = {
    members = [ "aaron" ];
  };
  users.users.aaron = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "input" # For Waybar to access input devices
      "audio" # For audio device access
      "video" # For video device access (e.g., GPU, webcam)
      "networkmanager" # For managing network connections
      "docker" # Optional: for Docker, if used
      "libvirtd" # Optional: for virtual machines, if used
      "kvm"
      "vboxusers" # For VirtualBox access
      "plugdev"
      "gamemode"
      "uinput"
      "wireshark"
    ]; # sudo and NetworkManager access
    initialPassword = "changeme"; # Change after install
    shell = pkgs.zsh;
  };

  # Enable zsh for proper shell integration
  programs.zsh.enable = true;

  # Ensure zsh is installed
  environment.systemPackages = with pkgs; [ zsh ];
  nix.settings.allowed-users = [ "@wheel" ];
}
