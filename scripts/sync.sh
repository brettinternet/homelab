#!/bin/bash

# TODO: change packages to `pacman` directory
# TODO: handle save/delete when pkg not on host

PRIVATE_ENV_FILE="$HOME/.env"
source "$PRIVATE_ENV_FILE"
SCRIPTS_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"
PACKAGES_DIR="${MY_PACKAGES:-$SCRIPTS_DIR/../pacman}"
SETTINGS_FILE_PATH="$HOME/.env"

if [[ "$DOTBOT_ACTION" = "setup" ]]; then
    $SCRIPTS_DIR/setup.sh
    while true; do
        read -p "Edit '$SETTINGS_FILE_PATH' to configure how the following script syncs environments. Continue? [Y/n]  " ANS
        ANS=${ANS:-y}
        case $ANS in
            [Yy]*)
                break;;
            [Nn]*)
                exit 0
                break;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
fi

### Error handle
if [[ ! -d "$PACKAGES_DIR" ]]; then
    echo "$PACKAGES_DIR is not a directory. You may set it in '$SETTINGS_FILE_PATH'"
    exit 1
fi

### Check if package lists are available
NO_PACKAGE_LISTS=false
[ -z "$(ls -A $PACKAGES_DIR)" ] && NO_PACKAGE_LISTS=true

sync () (
    ### Error handle
    if [ -z "$PACKAGE_LISTS" ]; then
        echo "$PACKAGE_LISTS is empty, please set this variable to comma-delimited package lists in $PACKAGES_DIR"
        exit 1
    fi

    commas_to_list () {
        # Convert to line delimited list, trim
        echo "$1" | tr ',' '\n' | awk '{$1=$1};1'
    }

    INCLUDE_AUR=false
    [[ -n "$FOREIGN_PACKAGE_LISTS" && -x "$(command -v yay)" ]] && INCLUDE_AUR=true

    DEFAULT_NATIVE_TXT="native.txt"
    DEFAULT_FOREIGN_TXT="aur.txt"
    IGNORE_TXT="${IGNORE_LIST:-ignore.txt}"

    # Get list, convert to array
    PACKAGE_LISTS=$(commas_to_list "$PACKAGE_LISTS") && PACKAGE_LISTS=($PACKAGE_LISTS)
    FIRST_PACKAGE_LIST="$(echo "${PACKAGE_LISTS[0]}" | cut -f 1 -d '.').txt"
    NATIVE_TXT=$([ -n "FIRST_PACKAGE_LIST" ] && echo "$FIRST_PACKAGE_LIST" || echo "$DEFAULT_NATIVE_TXT")
    if [ "$INCLUDE_AUR" = true ]; then
        FOREIGN_PACKAGE_LISTS=$(commas_to_list "$FOREIGN_PACKAGE_LISTS") && FOREIGN_PACKAGE_LISTS=($FOREIGN_PACKAGE_LISTS)
        FIRST_FOREIGN_PACKAGE_LIST="$(echo "${FOREIGN_PACKAGE_LISTS[0]}" | cut -f 1 -d '.').txt"
        FOREIGN_TXT=$([ -n "FIRST_FOREIGN_PACKAGE_LIST" ] && echo "$FIRST_FOREIGN_PACKAGE_LIST" || echo "$DEFAULT_FOREIGN_TXT")
    fi


    get_packages_from_lists () {
        LIST_NAMES=("$@")
        local PKGS=()
        for NAME in "${LIST_NAMES[@]}"; do
            NAME=$(echo "$NAME" | cut -f 1 -d '.')
            FILE_PATH="$PACKAGES_DIR/$NAME.txt"
            if [[ -f "$FILE_PATH" ]]; then
                LIST=$(sort "$FILE_PATH")
                PKGS+=($LIST)
            else
                echo "Unable to locate package list '$FILE_PATH' set in '$SETTINGS_FILE_PATH'." >&2
                exit 1
            fi
        done
        PKGS=$(IFS=$'\n'; echo "${PKGS[*]}")
        echo "$PKGS" | sort | uniq
    }

    LIST_OF_PACKAGES=$(get_packages_from_lists "${PACKAGE_LISTS[@]}")
    [ "$INCLUDE_AUR" = true ] && AUR_LIST_OF_PACKAGES=$(get_packages_from_lists "${FOREIGN_PACKAGE_LISTS[@]}")
    LOCALLY_INSTALLED_PACKAGES=$(comm -23 <(pacman -Qeq | sort) <(pacman -Qgq base base-devel | sort))
    LOCALLY_INSTALLED_NATIVE_PACKAGES=$(comm -23 <(pacman -Qeqn | sort) <(pacman -Qgq base base-devel | sort))
    LOCALLY_INSTALLED_FOREIGN_PACKAGES=$(comm -23 <(pacman -Qeqm | sort) <(echo "yay"))

    count_lines () {
        echo -n "$1" | grep -c '^'
    }

    # TODO: handle packages that should be removed (removed from remote, then to be removed from local)
    install_native () {
        local TO_INSTALL_LIST="$1"
        TO_INSTALL_LIST=$(comm -23 <(echo "$TO_INSTALL_LIST") <(echo "$LOCALLY_INSTALLED_PACKAGES"))
        local COUNT=$(count_lines "$TO_INSTALL_LIST")
        if [ "$COUNT" -gt "0" ]; then
            echo "Installing $COUNT native packages (--needed):"
            echo "$TO_INSTALL_LIST"
            sudo pacman -Sqyu --needed $(echo "$TO_INSTALL_LIST")
        else
            echo "No native packages to install"
        fi
    }

    install_foreign () {
        local TO_INSTALL_LIST="$1"
        TO_INSTALL_LIST=$(comm -23 <(echo "$TO_INSTALL_LIST") <(echo "$LOCALLY_INSTALLED_PACKAGES"))
        local COUNT=$(count_lines "$TO_INSTALL_LIST")
        if [ "$COUNT" -gt "0" ]; then
            echo "Installing $COUNT foreign packages (--needed):"
            echo "$TO_INSTALL_LIST"
            # --needed doesn't match pacman: https://github.com/Jguer/yay/issues/885
            yay -Sq --needed $(echo "$TO_INSTALL_LIST")
        else
            echo "No foreign packages to install"
        fi
    }


    # Confirm when items don't exist on system, in case intention is to remove
    #handle_save () {
        #local CR=`echo $'\n.'` && CR=${CR%.}
        #local LIST=($1)
        #local SAVE_FILE="$2"
        #local SAVE_FILE_PATH="$PACKAGES_DIR/$SAVE_FILE"
        #local TO_INSTALL=()
        #local TO_REMOVE=()
        #local INSTALL_ALL=false

        #for PKG in "${LIST[@]}"; do
            #while [ "$APPEND_ALL" = false ]; do
                #read -p "'$PKG' is installed locally. What do you want to do with '$PKG'?${CR}[u]ninstall, [S]kip, [a]ppend to $SAVE_FILE package list or [all], or add to [i]gnore list${CR}" ANS
                #ANS=${ANS:-s}
                #case ${ANS,,} in
                    #[u]*)
                        #TO_UNINSTALL+=( "$PKG" )
                        #break;;
                    #[s]*)
                        #break;;
                    #all)
                        #APPEND_ALL=true
                        #break;;
                    #[a]*)
                        #TO_APPEND+=( "$PKG" )
                        #break;;
                    #[i]*)
                        #TO_IGNORE+=( "$PKG" )
                        #break;;
                    #*)
                        #echo "Please answer u, s, a, all or i."
                        #;;
                #esac
            #done
            #[[ "$APPEND_ALL" = true ]] && TO_APPEND+=( "$PKG" )
        #done

        #TO_UNINSTALL=$(IFS=$'\n'; sort <<< "${TO_UNINSTALL[*]}")
        #TO_APPEND=$(IFS=$'\n'; sort <<< "${TO_APPEND[*]}")
        #TO_IGNORE=$(IFS=$'\n'; sort <<< "${TO_IGNORE[*]}")

        #TO_APPEND_COUNT=$(count_lines "$TO_APPEND")
        #if [[ "$TO_APPEND_COUNT" -gt "0" ]]; then
            #printf "Adding $TO_APPEND_COUNT packages to $SAVE_FILE list ($SAVE_FILE_PATH):\n$TO_APPEND\n"
            #echo "$TO_APPEND" >> "$SAVE_FILE_PATH"
            #sort -o "$SAVE_FILE_PATH" "$SAVE_FILE_PATH"
        #fi

        #TO_IGNORE_COUNT=$(count_lines "$TO_IGNORE")
        #if [[ "$TO_IGNORE_COUNT" -gt "0" ]]; then
            #printf "Adding $TO_IGNORE_COUNT packages to $IGNORE_FILE list ($IGNORE_FILE_PATH):\n$TO_IGNORE\n"
            #echo "$TO_IGNORE" >> "$IGNORE_FILE_PATH"
            #sort -o "$IGNORE_FILE_PATH" "$IGNORE_FILE_PATH"
        #fi

        #if [[ "$(count_lines "$TO_UNINSTALL")" -gt "0" ]]; then
            #sudo pacman -Rsn $(echo "$TO_UNINSTALL")
        #fi
    #}

    install () {
        install_native "$LIST_OF_PACKAGES"
        [ "$INCLUDE_AUR" = true ] && install_foreign "$AUR_LIST_OF_PACKAGES"
    }

    ###
    ###
    ###

    get_packages_from_all_lists () {
        local PKGS=()
        for FILE in $PACKAGES_DIR/*; do
            LIST=$(sort "$FILE")
            PKGS+=($LIST)
        done
        PKGS=$(IFS=$'\n'; echo "${PKGS[*]}")
        echo "$PKGS" | sort | uniq
    }

    handle_uninstall () {
        local CR=`echo $'\n.'` && CR=${CR%.}
        local LIST=($1)
        local SAVE_FILE="$2"
        local SAVE_FILE_PATH="$PACKAGES_DIR/$SAVE_FILE"
        local IGNORE_FILE="$3"
        IGNORE_FILE=$(echo "$IGNORE_FILE" | cut -f 1 -d '.')
        local IGNORE_FILE_PATH="$PACKAGES_DIR/$IGNORE_FILE.txt"
        local TO_UNINSTALL=()
        local TO_APPEND=()
        local TO_IGNORE=()
        local APPEND_ALL=false

        for PKG in "${LIST[@]}"; do
            while [ "$APPEND_ALL" = false ]; do
                read -p "'$PKG' is installed locally. What do you want to do with '$PKG'?${CR}[u]ninstall, [S]kip, [a]ppend to $SAVE_FILE package list or [all], or add to [i]gnore list${CR}" ANS
                ANS=${ANS:-s}
                case ${ANS,,} in
                    [u]*)
                        TO_UNINSTALL+=( "$PKG" )
                        break;;
                    [s]*)
                        break;;
                    all)
                        APPEND_ALL=true
                        break;;
                    [a]*)
                        TO_APPEND+=( "$PKG" )
                        break;;
                    [i]*)
                        TO_IGNORE+=( "$PKG" )
                        break;;
                    *)
                        echo "Please answer u, s, a, all or i."
                        ;;
                esac
            done
            [[ "$APPEND_ALL" = true ]] && TO_APPEND+=( "$PKG" )
        done

        TO_UNINSTALL=$(IFS=$'\n'; sort <<< "${TO_UNINSTALL[*]}")
        TO_APPEND=$(IFS=$'\n'; sort <<< "${TO_APPEND[*]}")
        TO_IGNORE=$(IFS=$'\n'; sort <<< "${TO_IGNORE[*]}")

        TO_APPEND_COUNT=$(count_lines "$TO_APPEND")
        if [[ "$TO_APPEND_COUNT" -gt "0" ]]; then
            printf "Adding $TO_APPEND_COUNT packages to $SAVE_FILE list ($SAVE_FILE_PATH):\n$TO_APPEND\n"
            echo "$TO_APPEND" >> "$SAVE_FILE_PATH"
            sort -o "$SAVE_FILE_PATH" "$SAVE_FILE_PATH"
        fi

        TO_IGNORE_COUNT=$(count_lines "$TO_IGNORE")
        if [[ "$TO_IGNORE_COUNT" -gt "0" ]]; then
            printf "Adding $TO_IGNORE_COUNT packages to $IGNORE_FILE list ($IGNORE_FILE_PATH):\n$TO_IGNORE\n"
            echo "$TO_IGNORE" >> "$IGNORE_FILE_PATH"
            sort -o "$IGNORE_FILE_PATH" "$IGNORE_FILE_PATH"
        fi

        if [[ "$(count_lines "$TO_UNINSTALL")" -gt "0" ]]; then
            sudo pacman -Rsn $(echo "$TO_UNINSTALL")
        fi
    }

    compare_installed () {
        local EXCLUDE_PACKAGE_LIST=$(get_packages_from_all_lists)
        local NATIVE_TO_UNINSTALL_LIST=$(comm -23 <(echo "$LOCALLY_INSTALLED_NATIVE_PACKAGES") <(echo "$EXCLUDE_PACKAGE_LIST"))
        local FOREIGN_TO_UNINSTALL_LIST=$(comm -23 <(echo "$LOCALLY_INSTALLED_FOREIGN_PACKAGES") <(echo "$EXCLUDE_PACKAGE_LIST"))

        NATIVE_DIFFERENCE_COUNT=$(count_lines "$NATIVE_TO_UNINSTALL_LIST")
        FOREIGN_DIFFERENCE_COUNT=$(count_lines "$FOREIGN_TO_UNINSTALL_LIST")

        if [[ "$NATIVE_DIFFERENCE_COUNT" -gt "0" ]]; then
            echo "You have $NATIVE_DIFFERENCE_COUNT native package(s) not recorded in your package lists."
            handle_uninstall "$NATIVE_TO_UNINSTALL_LIST" "$NATIVE_TXT" "$IGNORE_TXT"
        fi

        if [[ "$INCLUDE_AUR" = true && "$FOREIGN_DIFFERENCE_COUNT" -gt "0" ]]; then
            echo "You have $FOREIGN_DIFFERENCE_COUNT foreign package(s) not recorded in your package lists."
            handle_uninstall "$FOREIGN_TO_UNINSTALL_LIST" "$FOREIGN_TXT" "$IGNORE_TXT"
        fi
    }

    ###
    ###
    ###



    ### Install missing packages from lists
    install

    ### Remove host packages missing from lists,
    # confirm uninstallation with option to add to ignore
    compare_installed
)

if [[ "$NO_PACKAGE_LISTS" = false ]]; then
    sync
else
    echo "No package lists found in $PACKAGES_DIR."
fi

print_package_meta_data () {
    local ORPHAN_RESULTS=$(pacman -Qdt)
    if [[ -n "$ORPHAN_RESULTS" ]]; then
        echo "The following packages are orphans:"
        echo "$ORPHAN_RESULTS"
        echo "Use 'yay -Yc' to clean unneeded dependencies."
    fi
}


### Informational only
print_package_meta_data
