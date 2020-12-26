#!/bin/bash

alias mirror='sudo reflector --protocol https --latest 50 --number 20 --sort rate --save /etc/pacman.d/mirrorlist --verbose'

# Update pacman with yay
# Source: https://unix.stackexchange.com/a/384102/224048
# You may add "--console-log-level=warn" as an aria2 arg to simmer down `/etc/powerpill/powerpill.json`
pac() {
  # Downgrade permissions as AUR helpers expect to be run as a non-root user, $UID is read-only in {ba,z}sh
  export pacman_program="sudo -u #$UID /usr/bin/yay --pacman powerpill"

  # pacmatic needs to be run as root: https://github.com/keenerd/pacmatic/issues/35
  pacmatic_update() {
    sudo --preserve-env=pacman_program /usr/bin/pacmatic "$@"
  }

  if [[ -z "$@" ]]; then
    pacmatic_update -Syu
  else
    pacmatic_update "$@"
  fi
}

# Source: OMZ

# List all installed packages with a short description
function paclist() {
  # Source: https://bbs.archlinux.org/viewtopic.php?id=93683
  LC_ALL=C pacman -Qei $(pacman -Qu | cut -d " " -f 1) | \
    awk 'BEGIN {FS=":"} /^Name/{printf("\033[1;36m%s\033[1;37m", $2)} /^Description/{print $2}'
}

# List all disowned files in your system
function pacdisowned() {
  emulate -L zsh

  tmp=${TMPDIR-/tmp}/pacman-disowned-$UID-$$
  db=$tmp/db
  fs=$tmp/fs

  mkdir "$tmp"
  trap  '/bin/rm -rf "$tmp"' EXIT

  pacman -Qlq | sort -u > "$db"

  find /bin /etc /lib /sbin /usr ! -name lost+found \
    \( -type d -printf '%p/\n' -o -print \) | sort > "$fs"

  comm -23 "$fs" "$db"
}

# Open the website of an ArchLinux package
if [ -x "$(command -v xdg-open)" ]; then
    function pacweb() {
        pkg="$1"
        infos="$(pacman -Si "$pkg")"
        if [[ -z "$infos" ]]; then
          return
        fi
        repo="$(grep '^Repo' <<< "$infos" | grep -oP '[^ ]+$')"
        arch="$(grep '^Arch' <<< "$infos" | grep -oP '[^ ]+$')"
        xdg-open "https://www.archlinux.org/packages/$repo/$arch/$pkg/" &>/dev/null
    }
fi

# Pacman hygiene
function pacman_clean() {
  ORPHANS=$(pacman -Qtdq)
  if [[ $ORPHANS ]]; then
    # Remove pacman orphans
    sudo pacman -Rns $ORPHANS
  fi

  if [ -x "$(command -v xdg-open)" ]; then
    # Update configuration files
    # https://wiki.archlinux.org/index.php/Pacman/Pacnew_and_Pacsave
    sudo pacdiff
  else
    echo "Install pacdiff to update configuration files"
  fi

  # Clean up pacman cache
  sudo pacman -Sc
}

# Helpful Pacman cmds
function pacman_help {
    cat <<- EOF
sudo pacman -S 	Install packages from the repositories
sudo pacman -U 	Install a package from a local file
sudo pacman -S --asdeps 	Install packages as dependencies of another package
pacman -Qi 	Display information about a package in the local database
pacman -Qs 	Search for packages in the local database
sudo pacman -Qdt 	List all orphaned packages
sudo pacman -Syy 	Force refresh of all package lists after updating mirrorlist
sudo pacman -R 	Remove packages, keeping its settings and dependencies
sudo pacman -Rns 	Remove packages, including its settings and dependencies
pacman -Si 	Display information about a package in the repositories
pacman -Ss 	Search for packages in the repositories
sudo pacman -Rns $(pacman -Qtdq) 	Delete all orphaned packages
sudo pacman -Sy && sudo abs && sudo aur 	Update and refresh the local package, ABS and AUR databases
sudo pacman -Sy && sudo abs 	Update and refresh the local package and ABS databases
sudo pacman -Sy && sudo aur 	Update and refresh the local package and AUR databases
sudo pacman -Sy 	Update and refresh the local package database
sudo pacman -Syu 	Sync with repositories before upgrading packages
sudo pacman -Syu 	Sync with repositories before upgrading packages
sudo pacman -Fy 	Download fresh package databases from the server
pacman -Fs 	Search package file names for matching strings
pacman -Ql 	List files in a package
pacman -Qo 	Show which package owns a file
EOF
}

function yay_help {
    cat <<- EOF
yay -Pg 	Print current configuration
yay -S 	Install packages from the repositories
yay -U 	Install a package from a local file
yay -S --asdeps 	Install packages as dependencies of another package
yay -Qi 	Display information about a package in the local database
yay -Qs 	Search for packages in the local database
yay -Qe 	List installed packages including from AUR (tagged as "local")
yay -Syy 	Force refresh of all package lists after updating mirrorlist
yay -Qtd 	Remove orphans using yay
yay -R 	Remove packages, keeping its settings and dependencies
yay -Rns 	Remove packages, including its settings and unneeded dependencies
yay -Si 	Display information about a package in the repositories
yay -Ss 	Search for packages in the repositories
yay -Syu 	Sync with repositories before upgrading packages
yay -Syu --no-confirm 	Same as yaupg, but without confirmation
EOF
}
