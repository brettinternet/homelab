#!/usr/bin/env bash

# https://wiki.archlinux.org/index.php/Dictd
# Source: https://bbs.archlinux.org/viewtopic.php?pid=1633984#p1633984

# #!/usr/bin/env bash

# . "$XDG_CONFIG_HOME/dmenurc"
# DICT_CMD="$(which dict)"
# XCLIP_CMD="$(which xclip)"


# DICT="${1?-No dictionary set}" || exit 1
# WORD="${2}"
# if [ -z "$WORD" ]; then
#         WORD=$($XCLIP_CMD -o | $DMENU -p "Translate ($DICT):")
#         if [ -z "$WORD" ]; then
#                 exit 1
#         fi
# fi


# TRANSLATION=$($DICT_CMD -f -d "$DICT" "$WORD" 2>&1)
# case $? in
#         20)
#                 echo "$WORD" | $DMENU -p Nothing\ found:
#                 exit 1
#                 ;;
#         21)
#                 WORD="$(echo "$TRANSLATION" | awk 'NR>1 {print $4}' | $DMENU -p "Nothing found for $WORD. Did you mean:")"
#                 if [ -n "$WORD" ]; then
#                         TRANSLATION=$($DICT_CMD -f -d "$DICT" "$WORD" 2>&1)
#                         if [ "$?" != "0" ]; then
#                                 exit 1
#                         fi
#                 fi
#                 ;;
#         39)
#                 echo "$DICT" | $DMENU -p "Invalid Database:"
#                 exit 2
#                 ;;
# esac

# echo "$TRANSLATION" | awk '/^   /{gsub(/^[[:space:]]+/, ""); gsub("; ", "\n"); print}' | $DMENU -p "$WORD" | $XCLIP_CMD -i
