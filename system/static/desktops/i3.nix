{ config, lib, pkgs, ... }:

{
  # Enable X server for i3
  services.xserver.enable = true;

  # Install i3, polybar, and dmenu
  environment.systemPackages = with pkgs; [
    i3
    polybar
    dmenu
  ];

  # i3 configuration
  environment.etc."i3/config".text = ''
    # Basic i3 config
    set $mod Mod4
    font pango:monospace 10
    exec --no-startup-id polybar-msg cmd restart
    exec --no-startup-id polybar top
    bindsym $mod+Return exec i3-sensible-terminal
    bindsym $mod+d exec dmenu_run
    bindsym $mod+q kill
    bindsym $mod+Shift+e exec i3-nagbar -t warning -m 'Exit i3?' -b 'Yes' 'i3-msg exit'
    bar {
      status_command polybar top
      colors {
        background #222222
        statusline #ffffff
        separator #666666
      }
    }
  '';

  # Polybar configuration
  environment.etc."polybar/config".text = ''
    [bar/top]
    width = 100%
    height = 30
    background = #222222
    foreground = #ffffff
    modules-left = i3
    modules-right = date
    [module/i3]
    type = internal/i3
    [module/date]
    type = internal/date
    date = %Y-%m-%d %H:%M
  '';

  # xinitrc for user aaron to start i3
  environment.etc."X11/xinit/xinitrc.d/50-i3.sh".text = ''
    #!/bin/sh
    [ -f ~/.xinitrc ] && . ~/.xinitrc
    exec i3
  '';
}