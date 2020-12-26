#!/bin/bash

SCRIPTS_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"
DOTFILES_ROOT_DIR="$(cd $SCRIPTS_DIR && cd ../ && pwd)"

build_yay () {
    if ! [ -x "$(command -v yay)" ]; then
        echo "Installing yay"
        [ ! -d "$HOME/yay" ] && git clone https://aur.archlinux.org/yay.git $HOME/yay
        cd $HOME/yay && makepkg -si
    else
        echo "Yay is already installed"
    fi
}

MY_SHELL="${MY_SHELL:-bash}"
change_shell () {
    if [[ "$MY_SHELL" != "$SHELL" ]]; then
        echo "Changing shell to $MY_SHELL"
        chsh -s $(which "$MY_SHELL")
    fi
}

if [ "$SHELL" != "$MY_SHELL" ]; then
    while true; do
        read -p "Do you wish to change your shell to $MY_SHELL? [Y/n] " ANS
        ANS=${ANS:-Y}
        case $ANS in
            [Yy]*)
                change_shell
                break;;
            [Nn]*)
                break;;
            *)
                echo "Please answer yes or no."
                ;;
    esac
    done
else
    echo "\xE2\x9C\x94 Current shell is $SHELL"
fi

if ! hash yay 2>/dev/null; then
    while true; do
        read -p "Do you wish to install yay? [Y/n] " ANS
        ANS=${ANS:-Y}
        case $ANS in
            [Yy]*)
                build_yay
                break;;
            [Nn]*)
                break;;
            *)
                echo "Please answer yes or no."
                ;;
    esac
    done
else
    echo "\xE2\x9C\x94 yay is installed"
fi

while true; do
    read -p "Do you wish to run the defaults script to setup preferred defaults? [Y/n] " ANS
    ANS=${ANS:-Y}
    case $ANS in
        [Yy]*)
            source $SCRIPTS_DIR/defaults.sh
            break;;
        [Nn]*)
            break;;
        *)
            echo "Please answer yes or no."
            ;;
    esac
done

echo "Setup complete. Ready for sync."
