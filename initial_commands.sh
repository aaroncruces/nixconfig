nix-env -iA nixos.tmux
nix-env -iA nixos.htop
nix-env -iA nixos.git
tmux
rm install.sh -vf && nano install.sh && bash install.sh -d sda && less /mnt/etc/nixos/configuration.nix
nixos-install