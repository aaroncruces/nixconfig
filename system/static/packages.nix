{ config, lib, pkgs, ... }:

{
  # Allow non-free packages
  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = with pkgs; [
    firefox
    htop
    tmux
    neovim
    git
    gcc
    gnumake
    cmake
    binutils
    autoconf
    automake
    stow
    oh-my-posh
    psmisc
    kitty
    pcmanfm
  ];

  environment.systemPackages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
  };
  programs.gamemode.enable = true;
}