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
    pkgs.nerd-fonts.jetbrains-mono
    vscode
    efibootmgr
    gparted
    gvfs # Virtual filesystem support
    samba # SMB/CIFS support for network shares
    libmtp # MTP support for mobile devices
    lxmenu-data # Desktop menu entries for LXDE applications
    shared-mime-info # MIME type database for file associations
  ];

  # Enable GVFS services
  services.gvfs.enable = true;
  services.udisks2.enable = true; # For auto-mounting removable devices
  services.devmon.enable = true; # For auto-mounting removable devices


  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    };
  };
  
  programs.gamemode.enable = true;
}