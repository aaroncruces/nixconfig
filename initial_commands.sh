nix-env -iA nixos.tmux
nix-env -iA nixos.htop
nix-env -iA nixos.git
tmux

git clone https://github.com/aaroncruces/nixconfig.git
cd nixconfig
bash setup-nixos-configs.sh -d nvme0n1

nixos-install

find . -type f -name "*.nix" -exec bash -c 'echo "{}"; echo "----------------"; cat "{}"; echo -e "\n"' \; >> dump.txt

