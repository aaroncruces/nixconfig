{ config, lib, pkgs, ... }:

{
  ### to get the location of .fd on update:
  # virsh domcapabilities --machine pc-q35-9.2 | xmllint --xpath '/domainCapabilities/os' - 

  environment.systemPackages = with pkgs; [
    # Virtualization
    virt-manager # GUI for managing virtual machines
    swtpm # Software TPM emulator
    dnsmasq # Lightweight DNS forwarder and DHCP server
    virtio-win # VirtIO drivers for Windows guests
    win-spice # SPICE client for Windows
    virglrenderer # Virtual GPU renderer for QEMU
    cdrtools # CD/DVD/Blu-ray creation tools
  ];

  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "btrfs";
      daemon.settings = {
        features = {
          cdi = true; # Enables Container Device Interface for GPU passthrough
        };
      };
    };
    virtualbox.host = {
      enable = true;
      enableExtensionPack =
        true; # enables oracle extension pack for usb support
      enableKvm = true;
      addNetworkInterface =
        false; # modprobe disable kvm if needed to use not/nat network
    };
    libvirtd = {
      enable = true;
      qemu = {
        vhostUserPackages = with pkgs; [ virtiofsd ];
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
        # ovmf.packages = [ (pkgs.OVMFFull.override { secureBoot = true; tpmSupport = true; }).fd ];
      };
    };
    spiceUSBRedirection.enable = true; # enable usb redirection in virt-manager
  };

  # Enable virt-manager
  programs.virt-manager.enable = true;
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
  users.extraGroups.libvirtd.members = [ "user-with-access-to-virtualbox" ];

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
