nix-env -iA nixos.tmux
nix-env -iA nixos.htop
nix-env -iA nixos.git
tmux

git clone https://github.com/aaroncruces/nixconfig.git
cd nixconfig
bash setup-nixos-configs.sh -d nvme0n1
nixos-install

find . -type f -name "*.nix" -exec bash -c 'echo "{}"; cat "{}"; echo -e "\n"' \; >> dump.txt

mkdir -pv ~/gits
cd ~/gits
git clone https://github.com/mattmc3/antidote
git clone https://github.com/aaroncruces/dotfiles_stow
cd ~

# only once at the start (can delete important stuff)
rm -rvf ~/.config

cd ~/gits/dotfiles_stow
git pull
bash stow_uninstall_desktop.sh
bash stow_uninstall_common.sh
bash stow_install_common.sh
bash stow_install_desktop.sh


sudo su

cd /etc/nixos
git pull
nixos-rebuild switch

# diskpart
# select disk 0  # Assuming /dev/sda
# list partition
# select partition <efi_part_number>  # e.g., partition 4
# format quick fs=fat32 label="EFI"
# assign letter=S
# exit

# bcdboot C:\Windows /s S: /f UEFI
