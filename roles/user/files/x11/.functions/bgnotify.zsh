#!/usr/bin/env zsh

# Forked from https://github.com/t413/zsh-background-notify

# Alert when previous command is finished
# Usage: pacman -Syu; alert
# function alert {
#     ICON=$([ $? = 0 ] && echo terminal || echo error)
#     BODY=$(fc -ln -1)
#     # Set window to urgent via bell
#     echo -e "\a"
#     notify-send -u low -i "$ICON" "$BODY"
# }

## setup ##

[[ -o interactive ]] || return #interactive only!
zmodload zsh/datetime || { print "can't load zsh/datetime"; return } # faster than date()
autoload -Uz add-zsh-hook || { print "can't add zsh hook!"; return }

(( ${+bgnotify_threshold} )) || bgnotify_threshold=5 #default 5 seconds

## definitions ##

function bgnotify_formatted { ## args: (exit_status, command, elapsed_seconds, title)
    elapsed="$(( $3 % 60 ))s"
    (( $3 >= 60 )) && elapsed="$((( $3 % 3600) / 60 ))m $elapsed"
    (( $3 >= 3600 )) && elapsed="$(( $3 / 3600 ))h $elapsed"
    class="$4"
    icon=$([ $1 -eq 0 ] && echo "terminal" || echo "error")
    bgnotify "$class ($elapsed)" "$2" -i "$icon" -a "$class"
}

currentWindowId () {
    xprop -root 2> /dev/null | awk '/NET_ACTIVE_WINDOW/{print $5;exit} END{exit !$5}' || echo "0"
}

currentWindowClass () { ## args: (window ID)
    xprop -id "$1" WM_CLASS | awk '/WM_CLASS/{print $4;exit}' | sed -e 's/^"//' -e 's/"$//'
}

# dunst_notify () ( ## args: ...dunstify
#     handle_action () { ## args: (window ID)
#         if [ -n "$1" ] && hash i3-msg 2>/dev/null; then
#             i3-msg -q "[id=\"$1\"] focus"
#         else
#             notify-send -i "error" "Unable to handle action" "Cannot focus the terminal because 'i3' or the window ID is not found."
#         fi
#     }

#     ACTION_NAME="default"
#     ACTION=$(dunstify -A "$ACTION_NAME,Open Terminal" "$@")
#     [ "$ACTION" = "$ACTION_NAME" ] && handle_action "$bgnotify_windowid"
# )

bgnotify () { ## args: (title, subtitle)
    # if hash dunstify 2>/dev/null; then
        # dunst_notify "$@" &> /dev/null &
    # elif hash notify-send 2>/dev/null; then
        notify-send "$@"
    # fi
}

## Zsh hooks ##

bgnotify_begin() {
  bgnotify_timestamp=$EPOCHSECONDS
  bgnotify_lastcmd="$1"
  bgnotify_windowid=$(currentWindowId)
  bgnotify_windowclass=$(currentWindowClass "$bgnotify_windowid")
}

bgnotify_end() {
  didexit=$?
  elapsed=$(( EPOCHSECONDS - bgnotify_timestamp ))
  past_threshold=$(( elapsed >= bgnotify_threshold ))
  if (( bgnotify_timestamp > 0 )) && (( past_threshold )); then
    if [ $(currentWindowId) != "$bgnotify_windowid" ]; then
      print -n "\a"
      bgnotify_formatted "$didexit" "$bgnotify_lastcmd" "$elapsed" "$bgnotify_windowclass" &> /dev/null
    fi
  fi
  bgnotify_timestamp=0 #reset it to 0!
}

## only enable if a local (non-ssh) connection, and x is running
if [ -z "$SSH_CLIENT" ] && [ -z "$SSH_TTY" ] && xset q &>/dev/null; then
  add-zsh-hook preexec bgnotify_begin
  add-zsh-hook precmd bgnotify_end
fi
