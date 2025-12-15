{ config, lib, pkgs, ... }: {
  # Allow non-free packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    font-manager # GUI font selector and manager
  ];

  fonts.packages = with pkgs; [
    arkpandora_ttf # free truetype font collection
    corefonts # microsoft core fonts (arial, times new roman, etc.)
    font-awesome # iconic font and css toolkit
    nerd-fonts.jetbrains-mono # jetbrains mono font with programming ligatures
    vistafonts # microsoft vista fonts (calibri, consolas, etc.)
  ];
}
