{ config, lib, pkgs, ... }:

{
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