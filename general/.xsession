#!/bin/sh

# -- Display ----------------------------------------

# nvidia
export __GL_YIELD="USLEEP"
# Set for one monitor and once xrandr sets up other monitors, settings appear to propogate to other monitors
nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"
# https://wiki.archlinux.org/index.php/NVIDIA/Troubleshooting#Multi-monitor
# nvidia-settings --assign CurrentMetaMode="DP-0: nvidia-auto-select +2560+0 {ForceCompositionPipeline=On}, DP-1: nvidia-auto-select +0+0 {ForceCompositionPipeline=On}"

# xrandr
WORKSTATION="${MY_SCREENLAYOUT:-default}"
XRANDR_DIR="$HOME/.screenlayout"
bash -c $XRANDR_DIR/$WORKSTATION.sh

# -- System ----------------------------------------

# Turn off bell and
# set DPMS timeouts to zero https://wiki.archlinux.org/index.php/Display_Power_Management_Signaling#Modify_DPMS_and_screensaver_settings_with_a_command
# Instead of xss-lock responding to DPMS settings (https://wiki.archlinux.org/index.php/Session_lock#xss-lock), we use xidlehook below
# TODO: Perhaps this should be different if host is a laptop
xset -b dpms 0 0 0 s off

# systemd hook handler
# https://wiki.archlinux.org/index.php/Power_management#xss-lock
# important note about resuming from sleep:
# https://wiki.archlinux.org/index.php/Power_management#Sleep_hooks
xss-lock -- lock &

THIRTY_MIN=1800
LOCK_WARN_ID=6313
CLEAR_LOCK_WARN="dunstify -C $LOCK_WARN_ID"
xidlehook --not-when-fullscreen --not-when-audio \
    --timer $(($THIRTY_MIN - 30)) "dunstify -a 'system' -r $LOCK_WARN_ID -u critical -t 29000 'Locking soon...'" "$CLEAR_LOCK_WARN" \
    --timer 30 $MY_BIN/lock "$CLEAR_LOCK_WARN" \
    --timer $THIRTY_MIN 'systemctl hibernate' "$CLEAR_LOCK_WARN" &

xbindkeys
# Only use b:6 and b:7 with MX Master mouse, otherwise it's a handle to compete with x-axis scroll
if xinput | grep -q "Logitech MX Master"; then
    xbindkeys -f "$HOME/.xbindkeysrc-mouse"
fi

# Note: `experimental-backends` allows for dual kawase
# `no-fading-openclose`: https://wiki.archlinux.org/index.php/Picom#Slock_after_suspend
picom -b --experimental-backends --no-fading-openclose

feh --no-fehbg --randomize --bg-fill $MY_WALLPAPERS/* &

unclutter --timeout 3 &

greenclip daemon &> /dev/null &

LAT="40.8255921"
LON="-111.8084499"
redshift -l "$LAT:$LON" -m randr -t 6500:3000 &

if [[ "$IS_LAPTOP" = "true" ]]; then
    fusuma -d 2>&1
    # xinput set-prop 12 268 1 # for touchpad tap
fi

# -- Applets ----------------------------------------

nm-applet &
blueman-applet &

if [[ "$(solaar show 2>&1)" != *"Logitech receiver not found" ]]; then
    solaar -w hide &
fi

if [[ "$IS_LAPTOP" = "true" && -x "$(command -v cbatticon)" ]]; then
    cbatticon -u 20 -r 3 \
        -x notify-battery \
        -c "/usr/bin/systemctl hibernate" &
fi

# -- Workspace ----------------------------------------

# Initialize labeled alacritty window as i3 scratchpad
alacritty --class "alacritty-scratchpad1" &
alacritty --class "alacritty-scratchpad2" &
