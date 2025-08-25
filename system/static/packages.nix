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
    vscode
    efibootmgr
    gparted
    gvfs
    samba 
    libmtp 
    lxmenu-data
    lxappearance
    shared-mime-info
    nwg-look # gui icon selector 
    font-manager # gui font selector 
    rose-pine-cursor
    mpvpaper
    xdg-user-dirs
    peazip
    steam
    ntfs3g
    texliveFull
    remmina
    unzip
    obsidian
    featherpad
    vlc
    ffmpeg
    yt-dlp
    mpv
  ];

  fonts.packages = with pkgs; [
    arkpandora_ttf
    corefonts
    vistafonts
    nerd-fonts.jetbrains-mono
    font-awesome
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