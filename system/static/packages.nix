{ config, lib, pkgs, ... }: {
  # Allow non-free packages
  # nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Boot and partition tools
    efibootmgr
    f3
    gparted
    grub2
    ventoy

    # Browsers
    chromium
    firefox

    # CD/DVD/Blu-ray tools
    cdrdao
    cdrtools
    dvdplusrwtools
    kdePackages.k3b
    libdvdcss
    xorriso

    # Database tools
    dbeaver-bin

    # Desktop customization
    arandr
    libxcvt
    lxappearance
    lxmenu-data
    mpvpaper
    nwg-look
    rose-pine-cursor
    shared-mime-info
    xdg-user-dirs

    # Development tools
    ansible
    ansible-lint
    ansible-navigator
    autoconf
    automake
    azure-cli
    binutils
    busybox
    claude-code
    cmake
    entr
    gcc
    git
    gnumake
    graphviz
    jq
    lua
    lua-language-server
    molecule
    nixfmt-classic
    nodejs_24
    openjdk17-bootstrap
    openssl
    opentofu
    parallel
    plantuml
    pnpm
    postman
    python3
    ripgrep
    stow
    terraform
    yamllint

    # Document tools
    libreoffice
    onlyoffice-desktopeditors
    pandoc
    python3Packages.weasyprint
    texliveFull

    # Editors and IDEs
    featherpad
    neovim
    obsidian
    vscode

    # File managers and archivers
    filezilla
    gthumb
    ncdu
    p7zip
    pcmanfm
    peazip
    tree
    unrar-wrapper
    unzip
    zip

    # File systems and mounting
    e2fsprogs
    exfatprogs
    gvfs
    libmtp
    nfs-utils
    ntfs3g
    rclone
    samba

    # Gaming
    jstest-gtk
    lunar-client
    steam

    # Graphics and camera
    cheese
    exiftool
    gimp
    imagemagick

    # Media players and utilities
    ffmpeg
    mpv
    python313Packages.deemix
    vlc
    yt-dlp

    # Network tools
    inetutils
    iperf
    libxml2
    nmap
    socat

    # Remote access
    anydesk
    remmina
    sshpass

    # Security
    keepassxc

    # Serial tools
    picocom
    screen

    # System monitoring
    acpi
    dmidecode
    duf
    hdparm
    htop
    nss_latest
    pciutils
    psmisc
    pv
    smartmontools
    usbutils

    # Terminal tools
    expect
    ghostty
    kitty
    oh-my-posh
    tmux

    # Torrent clients
    qbittorrent

    # VPN
    openfortivpn
    openvpn
    wireguard-tools

    # Wayland screen capture
    grim
    slurp
    swappy
    wl-clipboard

  ];

  # for usb serial. change it to other file
  boot.kernelModules = [
    "usbserial"
    "ch341"
    "pl2303"
    "ftdi_sio"
    "cp210x"
    "8250"
    "serial8250"
    "8250_core"
  ];
  boot.kernelParams = [ "8250.nr_uarts=4" ];

  nixpkgs.config.permittedInsecurePackages =
    [ "ventoy-1.1.05" "ventoy-1.1.12" ];
  # Enable GVFS services
  services.gvfs.enable = true;
  services.udisks2.enable = true; # For auto-mounting removable devices
  services.devmon.enable = true; # For auto-mounting removable devices
  programs.gamemode.enable = true;

}
