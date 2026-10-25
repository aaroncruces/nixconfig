{ config, lib, pkgs, ... }:

let
  # Keep i3's binaries in the system profile, but do not export the upstream
  # raw i3.desktop entry. GDM was trying that entry as `Exec=i3` and failing
  # with "Cannot find a command for specified session: i3".
  i3Package = pkgs.symlinkJoin {
    name = "i3-without-upstream-session";
    paths = [ pkgs.i3 ];
    postBuild = ''
      rm -rf $out/share/xsessions
    '';
  };

  i3XorgSessionCommand = pkgs.writeShellScript "i3-xorg-session" ''
    systemctl --user import-environment PATH DISPLAY XAUTHORITY DESKTOP_SESSION XDG_CONFIG_DIRS XDG_DATA_DIRS XDG_RUNTIME_DIR XDG_SESSION_ID DBUS_SESSION_BUS_ADDRESS || true
    ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all || true
    exec ${i3Package}/bin/i3
  '';

  i3XorgSession = pkgs.writeTextFile {
    name = "i3-xorg-session-desktop";
    destination = "/share/xsessions/i3-xorg.desktop";
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=XSession
      Name=i3 Xorg
      Comment=i3 window manager on Xorg
      TryExec=${i3XorgSessionCommand}
      Exec=${i3XorgSessionCommand}
      DesktopNames=i3
    '';
  } // {
    providedSessions = [ "i3-xorg" ];
  };
in {
  services.xserver.enable = true;

  services.xserver.windowManager.i3 = {
    enable = true;
    package = i3Package;
    extraPackages = with pkgs; [ dmenu polybar picom xorg.xrandr ];
  };

  services.displayManager.sessionPackages = [ i3XorgSession ];
}
