{ config, lib, pkgs, ... }: {
  # Allow non-free packages
  # nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Boot and Partition Tools
    grub2 # GRUB2 boot loader
    efibootmgr # EFI boot manager configuration tool
    gparted # GNOME partition editor
    ventoy # Bootable USB creator for multiple ISOs
    xorriso # ISO filesystem manipulation tool
    cdrtools # CD/DVD/Blu-ray creation tools
    kdePackages.k3b # KDE CD/DVD/Blu-ray burning application
    f3 # Tool to test for fake flash drives and cards

    # Browsers
    chromium # Google Chrome browser
    firefox # Mozilla Firefox browser

    # Database Tools
    dbeaver-bin # Universal database management tool

    # Desktop Customization
    lxappearance # GTK theme and appearance configurator
    lxmenu-data # Desktop menu data for LXDE
    nwg-look # GUI GTK3 settings editor
    rose-pine-cursor # Rose Pine themed cursor theme
    shared-mime-info # MIME database and utilities
    xdg-user-dirs # Tool to manage user directories
    mpvpaper # Video wallpaper program using MPV

    # Development Tools
    autoconf # Automatic configure script builder
    automake # Tool for generating Makefile.in files
    azure-cli # Microsoft Azure command line interface
    binutils # Collection of binary tools
    claude-code # Anthropic Claude code assistant
    cmake # Cross-platform build system
    gcc # GNU compiler collection
    git # Distributed version control system
    gnumake # GNU implementation of make
    nodejs_24 # JavaScript runtime environment v24
    openssl # Cryptographic library and tools
    parallel # Shell tool for executing jobs in parallel
    postman # API development and testing platform
    stow # Symlink farm manager
    terraform # Infrastructure as code tool
    ansible # Automation and configuration management tool
    # ansible-lint # Linter for Ansible playbooks
    nixfmt-classic # Classic Nix code formatter
    plantuml # UML diagram generator
    graphviz # Graph visualization software
    openjdk17-bootstrap # OpenJDK 17 bootstrap
    python3 # Python 3 interpreter
    python314Full # Full Python 3.14 distribution
    busybox # Swiss army knife of embedded Linux utilities

    # Document Tools
    texliveFull # Complete TeX Live distribution
    pandoc # Universal document converter
    libreoffice # Open-source office suite
    onlyoffice-desktopeditors # Office suite compatible with MS Office

    # Editors and IDEs
    featherpad # Lightweight Qt text editor
    neovim # Modern Vim-based text editor
    obsidian # Knowledge management and note-taking app
    vscode # Visual Studio Code editor

    # File Managers and Archivers
    pcmanfm # Lightweight file manager for LXDE
    peazip # Cross-platform file archiver
    unzip # Extraction utility for ZIP archives
    zip # Compression utility for ZIP archives
    filezilla # FTP/SFTP client
    gthumb # Image viewer and organizer
    ncdu # NCurses disk usage analyzer
    tree # Directory tree listing tool

    # File Systems and Mounting
    gvfs # GNOME virtual file system
    libmtp # Library for MTP device access
    ntfs3g # NTFS filesystem driver with read/write support
    samba # SMB/CIFS file sharing protocol implementation
    nfs-utils # NFS client and server utilities
    rclone # Rsync for cloud storage

    # Gaming
    jstest-gtk # Joystick testing and configuration tool
    steam # Digital distribution platform for games

    # Media Players
    mpv # Command-line media player
    vlc # Versatile media player

    # Media Utilities
    ffmpeg # Multimedia framework for audio/video processing
    yt-dlp # YouTube and media downloader

    # Network Tools
    inetutils # GNU network utilities
    iperf # Network performance measurement tool
    nmap # Network discovery and security auditing tool
    jq # Command-line JSON processor

    # Remote Access
    remmina # Remote desktop client
    sshpass # Non-interactive SSH password provider

    # Security
    keepassxc # Cross-platform password manager

    # System Monitoring
    htop # Interactive process viewer
    psmisc # Utilities for managing processes
    acpi # ACPI information tool
    hdparm # Hard disk parameter tool
    smartmontools # SMART disk monitoring tools
    usbutils # USB device listing utilities
    nss_latest # Latest Network Security Services library

    # Terminal Tools
    ghostty # Fast terminal emulator
    kitty # GPU-accelerated terminal emulator
    oh-my-posh # Cross-platform prompt theme engine
    tmux # Terminal multiplexer

    # Torrent Clients
    qbittorrent # BitTorrent client

    # VPN
    openfortivpn # Client for Fortinet VPN
    openvpn # Open source VPN solution

    # Miscellaneous
    expect # Tool for automating interactive applications

    gparted

    duf

    libxml2 

    gimp
  ];

  nixpkgs.config.permittedInsecurePackages = [ "ventoy-1.1.05" ];
  # Enable GVFS services
  services.gvfs.enable = true;
  services.udisks2.enable = true; # For auto-mounting removable devices
  services.devmon.enable = true; # For auto-mounting removable devices
  programs.gamemode.enable = true;

}