{ config, pkgs, lib, ... }:

{
  imports =
    [
      (import "${home-manager}/nixos")
    ];

  # Add home-manager to system packages
  environment.systemPackages = with pkgs; [
    home-manager
  ];
  home-manager.users.aaron = { pkgs, ... }: {
    home.packages = [ pkgs.btop pkgs.httpie ];
    programs.bash.enable = true;
  
    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "25.05";
  };
}