{ config, lib, pkgs, ... }:

{
  # Allow non-free packages
  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = with pkgs; [
    # Browsers
    firefox
    chromium

    # Desktop Customization
    font-manager # gui font selector
    lxappearance
    lxmenu-data
    nwg-look # gui icon selector
    rose-pine-cursor
    shared-mime-info
    xdg-user-dirs

    # Development Tools
    autoconf
    automake
    binutils
    cmake
    gcc
    git
    gnumake
    stow
    parallel

    # Document Tools
    texliveFull

    # Editors and IDEs
    featherpad
    neovim
    obsidian
    vscode
    onlyoffice-desktopeditors

    # File Managers and Archivers
    pcmanfm
    peazip
    unzip

    # File Systems and Mounting
    gvfs
    libmtp
    ntfs3g
    samba

    # Gaming
    steam

    # Media Players
    mpv
    vlc

    # Media Utilities
    #ffmpeg
    yt-dlp

    # Partition and Boot Tools
    efibootmgr
    gparted

    # Remote Access
    remmina

    # System Monitoring
    htop
    psmisc

    # Terminal Tools
    kitty
    ghostty
    oh-my-posh
    tmux

    # VPN
    openfortivpn
    openvpn

    # Wallpaper
    mpvpaper

    jstest-gtk
    dbeaver-bin
    openssl
    claude-code
    nodejs_24
    
    postman
    
    keepassxc

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
    virtualbox.host.enable = true;
    docker = {
      enable = true;
      storageDriver = "btrfs";
      daemon.settings = {
        features = {
          cdi = true;  # Enables Container Device Interface for GPU passthrough
        };
      };
    };
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    };
    oci-containers.backend = "docker";
  };

  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];

  hardware.xpadneo.enable = true;
  programs.gamemode.enable = true;
}