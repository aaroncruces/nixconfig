nix-env -iA nixos.tmux
nix-env -iA nixos.htop
nix-env -iA nixos.git
tmux

git clone https://github.com/aaroncruces/nixconfig.git
cd nixconfig
bash setup-nixos-configs.sh -d sda
ls -la  /mnt/etc/nixos/

nixos-install