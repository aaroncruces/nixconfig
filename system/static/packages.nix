{ config, lib, pkgs, ... }:
{
  # Allow non-free packages
  nixpkgs.config.allowUnfree = true;
 
  environment.systemPackages = with pkgs; [
    # Browsers
    chromium # google chrome browser
    firefox # mozilla firefox browser
    # Database Tools
    dbeaver-bin # universal database management tool
    # Desktop Customization
    font-manager # gui font selector and manager
    lxappearance # gtk theme and appearance configurator
    lxmenu-data # desktop menu data for lxde
    nwg-look # gui gtk3 settings editor
    rose-pine-cursor # rose pine themed cursor theme
    shared-mime-info # mime database and utilities
    xdg-user-dirs # tool to manage user directories
    # Development Tools
    autoconf # automatic configure script builder
    automake # tool for generating makefile.in files
    azure-cli # microsoft azure command line interface
    binutils # collection of binary tools
    claude-code # anthropic claude code assistant
    cmake # cross-platform build system
    gcc # gnu compiler collection
    git # distributed version control system
    gnumake # gnu implementation of make
    nodejs_24 # javascript runtime environment v24
    openssl # cryptographic library and tools
    parallel # shell tool for executing jobs in parallel
    postman # api development and testing platform
    stow # symlink farm manager
    # Document Tools
    texliveFull # complete tex live distribution
    # Editors and IDEs
    featherpad # lightweight qt text editor
    neovim # modern vim-based text editor
    obsidian # knowledge management and note-taking app
    onlyoffice-desktopeditors # office suite compatible with ms office
    vscode # visual studio code editor
    # File Managers and Archivers
    pcmanfm # lightweight file manager for lxde
    peazip # cross-platform file archiver
    unzip # extraction utility for zip archives
    # File Systems and Mounting
    gvfs # gnome virtual file system
    libmtp # library for mtp device access
    ntfs3g # ntfs filesystem driver with read/write support
    samba # smb/cifs file sharing protocol implementation
    # Gaming
    jstest-gtk # joystick testing and configuration tool
    steam # digital distribution platform for games
    # Media Players
    mpv # command-line media player
    vlc # versatile media player
    # Media Utilities
    #ffmpeg # multimedia framework for audio/video processing
    yt-dlp # youtube and media downloader
    # Partition and Boot Tools
    efibootmgr # efi boot manager configuration tool
    gparted # gnome partition editor
    # Remote Access
    remmina # remote desktop client
    # Security
    keepassxc # cross-platform password manager
    # System Monitoring
    htop # interactive process viewer
    psmisc # utilities for managing processes
    # Terminal Tools
    ghostty # fast terminal emulator
    kitty # gpu-accelerated terminal emulator
    oh-my-posh # cross-platform prompt theme engine
    tmux # terminal multiplexer
    # Virtualization
    virt-manager # gui for managing virtual machines
    swtpm
    dnsmasq
    virtio-win
    win-spice
    virglrenderer
    cdrtools
    # VPN
    openfortivpn # client for fortinet vpn
    openvpn # open source vpn solution
    # Wallpaper
    mpvpaper # video wallpaper program using mpv

    nixfmt
  ];
  fonts.packages = with pkgs; [
    arkpandora_ttf # free truetype font collection
    corefonts # microsoft core fonts (arial, times new roman, etc.)
    font-awesome # iconic font and css toolkit
    nerd-fonts.jetbrains-mono # jetbrains mono font with programming ligatures
    vistafonts # microsoft vista fonts (calibri, consolas, etc.)
  ];
  # Enable GVFS services
  services.gvfs.enable = true;
  services.udisks2.enable = true; # For auto-mounting removable devices
  services.devmon.enable = true; # For auto-mounting removable devices
  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "btrfs";
      daemon.settings = {
        features = {
          cdi = true;  # Enables Container Device Interface for GPU passthrough
        };
      };
    };
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true; # enables oracle extension pack for usb support
      enableKvm = true;
      addNetworkInterface = false; # modprobe disable kvm if needed to use not/nat network
    };
    libvirtd = {
      enable = true;
      qemu = {
      vhostUserPackages = with pkgs; [ virtiofsd ];
      swtpm.enable = true;
      ovmf.enable = true;
      ovmf.packages = [ pkgs.OVMFFull.fd ];
    };
    };
    spiceUSBRedirection.enable = true; # enable usb redirection in virt-manager
  };
  # Enable virt-manager
  programs.virt-manager.enable = true;
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
  users.extraGroups.libvirtd.members = [ "user-with-access-to-virtualbox" ];
  hardware.xpadneo.enable = true;
  programs.gamemode.enable = true;

  # Automatically create virtio-win.iso on activation
  system.activationScripts.createVirtioIso = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/libvirt/images
    if [ ! -f /var/lib/libvirt/images/virtio-win.iso ]; then
      ${pkgs.cdrtools}/bin/mkisofs -o /var/lib/libvirt/images/virtio-win.iso -J -R ${pkgs.virtio-win}
      chown root:kvm /var/lib/libvirt/images/virtio-win.iso
      chmod 644 /var/lib/libvirt/images/virtio-win.iso
    fi
  '';

environment.etc."qemu/bridge.conf" = {
  text = ''
    allow br0
    allow virbr0
  '';
};





}