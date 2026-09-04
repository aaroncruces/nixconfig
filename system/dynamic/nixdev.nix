{ config, lib, pkgs, ... }:

let
  # Import the reusable bridge/address-cascade builder. This keeps host-specific
  # networking policy in this file while putting the shared implementation in
  # system/lib/.
  networkmanagerBridgeAddressCascade =
    import ../lib/networkmanager-bridge-address-cascade.nix {
      inherit lib pkgs;
    };

  # Build the complete NetworkManager configuration fragment for nixdev's wired
  # bridge. The result contains two pieces used below:
  #   - dispatcherScript: the NetworkManager dispatcher hook.
  #   - profiles: the bridge, fallback, and bridge-slave connection profiles.
  nixdevBridgeAddressCascade =
    networkmanagerBridgeAddressCascade.mkBridgeDhcpAddressCascade {
      # Name of the Linux bridge interface exposed to the rest of the system.
      bridgeInterface = "br0";

      # Physical NIC that NetworkManager enslaves into the bridge.
      ethernetInterface = "enp8s0";

      # NetworkManager tries DHCP first. If no DHCP server answers within the
      # timeout, it falls back to the static profile below.

      # Declarative NetworkManager profile ID for the normal DHCP bridge.
      dhcpProfileId = "bridge-br0";

      # Declarative NetworkManager profile ID for the no-DHCP fallback bridge.
      noDhcpFallbackProfileId = "bridge-br0-static-fallback";

      # Static IPv4 address used when the fallback profile is activated.
      noDhcpFallbackAddress = "200.200.200.12";

      # Preferred stable host addresses for LANs identified by their DHCP server.
      # Unknown DHCP servers keep the ordinary DHCP lease.
      dhcpServerAddressRules = [
        {
          # Highest-priority rule: CEIM-style network or equivalent static LAN.
          dhcpServerAddress = "200.200.200.2";
          preferredHostAddress = "200.200.200.12";
        }
        {
          # 192.168.240.x LAN.
          dhcpServerAddress = "192.168.240.1";
          preferredHostAddress = "192.168.240.3";
        }
        {
          # 192.168.120.x LAN.
          dhcpServerAddress = "192.168.120.1";
          preferredHostAddress = "192.168.120.3";
        }
        {
          # 192.168.2.x LAN.
          dhcpServerAddress = "192.168.2.1";
          preferredHostAddress = "192.168.2.14";
        }
        {
          # 192.168.1.x LAN.
          dhcpServerAddress = "192.168.1.1";
          preferredHostAddress = "192.168.1.14";
        }
      ];
    };
in {
  # Apply this file only when the current machine's hostname is nixdev.
  config = lib.mkIf (config.networking.hostName == "nixdev") {
    # Mount NTFS partition at /winfs
    fileSystems."/winfs" = lib.mkForce {
      device = "/dev/disk/by-uuid/72563F3E563F0281";
      fsType = "ntfs";
      options = [
        "defaults"
        "nofail"
        "uid=1000"
        "gid=100"
        "dmask=022"
        "fmask=133"
      ]; # User-readable, aaron access
    };

    fileSystems."/vm" = {
      device = "/dev/disk/by-uuid/4ac05c37-3661-489d-bb85-2697bff25cc2";
      fsType = "btrfs";
      options = [
        "nofail" # Don't fail boot if mount fails
        "subvol=vm" # Mount the vm subvolume
        "nodatacow" # Disable copy-on-write for better VM performance
        "compress=lzo" # Fast compression algorithm
        "space_cache=v2" # Efficient space cache for performance
        "noatime" # Don't update file access times
        "discard=async" # Async SSD TRIM for better performance
      ];
    };

    services.openssh.ports = [ 1814 ];

    # Enable NetworkManager as the only network configuration manager.
    networking.networkmanager.enable = true;

    # Disable NixOS' legacy DHCP path so it does not race NetworkManager.
    networking.useDHCP = false;

    # Prevent the physical NIC from being configured directly; it is a bridge
    # slave and gets connectivity through br0.
    networking.interfaces.enp8s0.useDHCP = false;

    # Keep the unmanaged list empty so NetworkManager can own br0 and enp8s0.
    networking.networkmanager.unmanaged = [ ];

    # Do not block boot on wired network detection or DHCP timeouts.
    systemd.services."NetworkManager-wait-online".enable = false;

    # Install the generated dispatcher hook into
    # /etc/NetworkManager/dispatcher.d. It runs after DHCP events on br0.
    networking.networkmanager.dispatcherScripts =
      [ nixdevBridgeAddressCascade.dispatcherScript ];

    # Generated bridge, no-DHCP fallback, and bridge-slave profiles.
    networking.networkmanager.ensureProfiles.profiles =
      nixdevBridgeAddressCascade.profiles;

  };
}
