{ lib, pkgs }:

{
  /* Function: mkBridgeDhcpAddressCascade

     Build a NetworkManager bridge whose preferred IPv4 address depends on the
     DHCP server that answers on the current LAN.

     NetworkManager can declaratively create the bridge and DHCP/static fallback
     profiles, but it cannot choose a static address from the DHCP server address
     alone. That value only exists after DHCP has run. The dispatcher hook below
     is the narrow runtime part: it observes the DHCP server on "up" and
     "dhcp4-change" events, then swaps only the managed addresses for this rule.

     A host file should pass:
       - bridgeInterface / ethernetInterface: the NetworkManager bridge pair.
       - dhcpProfileId: the normal DHCP bridge profile.
       - noDhcpFallbackProfileId / noDhcpFallbackAddress: lower-priority static
         profile used when no DHCP server answers.
       - dhcpServerAddressRules: ordered DHCP server -> preferred address rules.
  */
  mkBridgeDhcpAddressCascade = settings:
    let
      # Required setting: Linux bridge interface name, for example "br0".
      bridgeInterface = settings.bridgeInterface;

      # Required setting: physical Ethernet interface enslaved into the bridge.
      ethernetInterface = settings.ethernetInterface;

      # Required setting: NetworkManager connection ID for the DHCP bridge.
      dhcpProfileId = settings.dhcpProfileId;

      # Required setting: NetworkManager connection ID for the static fallback.
      noDhcpFallbackProfileId = settings.noDhcpFallbackProfileId;

      # Required setting: IPv4 address used by the static fallback profile.
      noDhcpFallbackAddress = settings.noDhcpFallbackAddress;

      # Required setting: ordered list of DHCP-server-address match rules.
      # Each rule has:
      #   - dhcpServerAddress: address advertised by the DHCP server.
      #   - preferredHostAddress: stable address to assign to the bridge.
      dhcpServerAddressRules = settings.dhcpServerAddressRules;

      # Optional setting: IPv4 prefix length used for every managed address.
      prefixLength = settings.prefixLength or 24;

      # Optional setting: how long NetworkManager waits before DHCP may fail.
      dhcpTimeoutSeconds = settings.dhcpTimeoutSeconds or 20;

      # Optional setting: priority for the normal DHCP profile.
      dhcpAutoconnectPriority = settings.dhcpAutoconnectPriority or 100;

      # Optional setting: lower priority for the no-DHCP fallback profile.
      noDhcpAutoconnectPriority = settings.noDhcpAutoconnectPriority or (-100);

      # All addresses this helper owns. The dispatcher removes only these
      # addresses when switching LANs, leaving unrelated manual addresses alone.
      managedStaticAddresses = lib.unique ([ noDhcpFallbackAddress ]
        ++ map (rule: rule.preferredHostAddress) dhcpServerAddressRules);

      # CIDR form of managedStaticAddresses, ready for `ip address` commands.
      managedStaticCidrs = map (address: "${address}/${toString prefixLength}")
        managedStaticAddresses;

      # Shell `case` branches generated from the ordered rule list. Keeping the
      # ordering here preserves the cascade order from the host config.
      dhcpServerCaseBody = lib.concatMapStringsSep "\n" (rule: ''
        ${lib.escapeShellArg rule.dhcpServerAddress})
          selected_static_address=${
            lib.escapeShellArg rule.preferredHostAddress
          }
          ;;
      '') dhcpServerAddressRules;

      # Generated dispatcher script source. Nix substitutes only immutable
      # values and store paths; the runtime script remains a plain shell file.
      dispatcherSource = pkgs.replaceVarsWith {
        # Store derivation name for the generated dispatcher hook.
        name = "networkmanager-${bridgeInterface}-dhcp-address-cascade";

        # Shell template kept beside this Nix helper for readability.
        src = ./networkmanager-bridge-address-cascade.sh;

        # NetworkManager dispatcher scripts must be executable.
        isExecutable = true;

        # Values injected into @placeholder@ markers in the shell template.
        replacements = {
          # Runtime shell used in the generated script shebang.
          runtimeShell = "${pkgs.runtimeShell}";

          # Prefix length appended to the selected preferredHostAddress.
          prefixLength = toString prefixLength;

          # Generated `case` body for DHCP server address matching.
          inherit dhcpServerCaseBody;

          # Shell-quoted bridge interface name.
          bridgeInterfaceShell = lib.escapeShellArg bridgeInterface;

          # Shell-quoted fallback profile ID.
          noDhcpFallbackProfileIdShell =
            lib.escapeShellArg noDhcpFallbackProfileId;

          # Shell-quoted space-separated list of CIDRs owned by this helper.
          managedStaticCidrListShell =
            lib.escapeShellArg (lib.concatStringsSep " " managedStaticCidrs);

          # Absolute nmcli path in the Nix store.
          nmcliShell = lib.escapeShellArg "${pkgs.networkmanager}/bin/nmcli";

          # Absolute iproute2 `ip` path in the Nix store.
          ipShell = lib.escapeShellArg "${pkgs.iproute2}/bin/ip";

          # Absolute awk path in the Nix store.
          awkShell = lib.escapeShellArg "${pkgs.gawk}/bin/awk";

          # Absolute logger path in the Nix store.
          loggerShell = lib.escapeShellArg "${pkgs.util-linux}/bin/logger";
        };
      };
    in {
      # NetworkManager dispatcher hook declaration consumed by
      # networking.networkmanager.dispatcherScripts.
      dispatcherScript = {
        # Executable script generated from the template above.
        source = dispatcherSource;

        # "basic" places the hook directly in dispatcher.d and lets the script
        # filter its own events.
        type = "basic";
      };

      # NetworkManager connection profiles consumed by
      # networking.networkmanager.ensureProfiles.profiles.
      profiles = {
        # Normal bridge profile. It starts with DHCP so the dispatcher can learn
        # which DHCP server answered on the current LAN.
        ${dhcpProfileId} = {
          # NetworkManager connection metadata for the bridge.
          connection = {
            # Stable profile ID visible in nmcli/nmtui.
            id = dhcpProfileId;

            # NetworkManager connection type.
            type = "bridge";

            # Linux interface name created by this bridge profile.
            interface-name = bridgeInterface;

            # Bring this profile up automatically.
            autoconnect = true;

            # Prefer DHCP over the no-DHCP fallback profile.
            autoconnect-priority = dhcpAutoconnectPriority;
          };

          # IPv4 behavior for the normal bridge profile.
          ipv4 = {
            # Start with DHCP; the dispatcher replaces the lease address only
            # when the DHCP server is one of the known LAN identifiers.
            method = "auto";

            # Treat DHCP failure as profile failure so the fallback can activate.
            may-fail = false;

            # DHCP wait time before NetworkManager can try lower-priority paths.
            dhcp-timeout = dhcpTimeoutSeconds;
          };

          # Kernel bridge settings for the normal profile.
          bridge = {
            # Disable spanning tree for this simple local bridge.
            stp = false;

            # Forwarding database ageing time in seconds.
            ageing-time = 300;
          };
        };

        # Static fallback bridge profile. This handles the "no DHCP server"
        # branch without custom DHCP probing logic in the dispatcher.
        ${noDhcpFallbackProfileId} = {
          # NetworkManager connection metadata for the fallback bridge.
          connection = {
            # Stable fallback profile ID visible in nmcli/nmtui.
            id = noDhcpFallbackProfileId;

            # NetworkManager connection type.
            type = "bridge";

            # Same bridge interface as the DHCP profile.
            interface-name = bridgeInterface;

            # Allow NetworkManager to activate this automatically.
            autoconnect = true;

            # Lower priority means DHCP gets the first chance.
            autoconnect-priority = noDhcpAutoconnectPriority;
          };

          # IPv4 behavior for the fallback bridge profile.
          ipv4 = {
            # Manual static address used when DHCP is unavailable.
            method = "manual";

            # Static address plus prefix length for the fallback LAN.
            addresses = "${noDhcpFallbackAddress}/${toString prefixLength}";

            # Avoid installing a default route for the fallback-only network.
            never-default = true;
          };

          # Disable IPv6 on the fallback profile to avoid partial fallback state.
          ipv6 = { method = "ignore"; };

          # Kernel bridge settings for the fallback profile.
          bridge = {
            # Disable spanning tree for this simple local bridge.
            stp = false;

            # Forwarding database ageing time in seconds.
            ageing-time = 300;
          };
        };

        # Ethernet slave profile. It attaches the physical NIC to the bridge.
        "bridge-slave-${ethernetInterface}" = {
          # NetworkManager connection metadata for the physical bridge port.
          connection = {
            # Stable profile ID derived from the physical interface name.
            id = "bridge-slave-${ethernetInterface}";

            # NetworkManager connection type for a wired NIC.
            type = "ethernet";

            # Physical interface managed by this slave profile.
            interface-name = ethernetInterface;

            # Bridge master connection/interface name.
            master = bridgeInterface;

            # Tell NetworkManager this Ethernet profile is a bridge slave.
            slave-type = "bridge";

            # Bring the physical port up automatically with the bridge.
            autoconnect = true;
          };
        };
      };
    };
}
