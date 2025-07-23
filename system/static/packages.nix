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
    antidote
    psmisc
    kitty
  ];
}