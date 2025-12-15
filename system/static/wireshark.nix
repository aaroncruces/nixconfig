{ config, lib, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    wireshark # Packet analyzer
  ];

  programs.wireshark = {
    enable = true;
    package =
      pkgs.wireshark; # Optional: specify if you want a particular variant, like pkgs.wireshark-qt
  };

}
