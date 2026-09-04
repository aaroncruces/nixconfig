# /etc/nixos/nomachine.nix
{ config, pkgs, ... }:

let
  nomachinePkg = pkgs.requireFile rec {
    name = "nomachine_9.7.3_1_x86_64.tar.gz";
    url = "https://web9001.nomachine.com/download/9.7/Linux/nomachine_9.7.3_1_x86_64.tar.gz";
    sha256 = "013wpqd4xld6fyyygbpqhlzp9kyln2248697m0cd0pz7xdmdfzja";
    message = ''
      Please download the NoMachine tarball manually:

        https://web9001.nomachine.com/download/9.7/Linux/nomachine_9.7.3_1_x86_64.tar.gz

      and add it to the Nix store with:

        nix-store --add-fixed sha256 ${name}
    '';
  };

  nomachineInstalled = pkgs.stdenv.mkDerivation {
    pname = "nomachine";
    version = "9.7.3";
    src = nomachinePkg;

    nativeBuildInputs = with pkgs; [ makeWrapper ];

    installPhase = ''
      mkdir -p $out/opt $out/share/applications

      tar -xzf $src -C $out/opt

      cd $out/opt/NX
      NX_INSTALL_PREFIX=$out/opt ./nxserver --install redhat

      cat > $out/share/applications/nomachine.desktop <<EOF
[Desktop Entry]
Name=NoMachine
Comment=High-performance remote desktop
Exec=$out/opt/NX/bin/nxplayer
Icon=$out/opt/NX/share/icons/nomachine.png
Terminal=false
Type=Application
Categories=Network;RemoteAccess;
StartupNotify=true
EOF
    '';

    meta = with pkgs.lib; {
      description = "NoMachine remote desktop";
      platforms = platforms.linux;
    };
  };
in
{
  environment.systemPackages = [ nomachineInstalled ];
}