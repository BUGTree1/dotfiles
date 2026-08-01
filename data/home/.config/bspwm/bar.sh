#!/usr/bin/env bash

SCRIPT_FILE=$(realpath "${0}")
SCRIPT_DIR=$(dirname "${SCRIPT_FILE}")

if [ -z "$1" ]; then
    for mon in $(bspc query -M --names); do
        "${BASH}" "${SCRIPT_FILE}" "${mon}" &
    done
    wait
    exit
fi

MONITOR="$1"

# --- Configuration ---
# lemonbar uses #AARRGGBB format.
BG="#88112244"
FG="#FF7788FF"

# Battery Discharge text colors
DCH_BG="#FFFF8877"
DCH_FG="#88442211"

# Font configuration (Requires lemonbar to be compiled with XFT support)
FONT="Hack\ Nerd\ Font\ Mono:style=Bold:size=10"

# Path to the battery power_supply directory which will be shown in the bar
BATTERY_PATH="/sys/class/power_supply/BAT1"

# --- Setup Named Pipe (FIFO) ---
FIFO="/tmp/lemonbar_fifo_${MONITOR}_$$"
mkfifo "$FIFO"

trap 'rm -f "$FIFO"; kill $(jobs -p) 2>/dev/null' EXIT INT TERM

# --- 1. Clock Generator ---
(
    while true; do
        BATTERY_STATUS="UNK"
        BATTERY_SYS_STATUS=$(cat "${BATTERY_PATH}/status")
        $( echo "${BATTERY_SYS_STATUS}" | grep -q -i "charging" ) && {
            BATTERY_STATUS="CHG"
        }
        $( echo "${BATTERY_SYS_STATUS}" | grep -q -i "not charging" ) && {
            BATTERY_STATUS="NCH"
        }
        $( echo "${BATTERY_SYS_STATUS}" | grep -q -i "discharging" ) && {
            BATTERY_STATUS="%{F${DCH_FG}}%{B${DCH_BG}}DCH%{F-}%{B-}"
        }
        $( echo "${BATTERY_SYS_STATUS}" | grep -q -i "full" ) && {
            BATTERY_STATUS="FUL"
        }

        echo "T ${BATTERY_STATUS} $(cat ${BATTERY_PATH}/capacity)% $(date '+%Y-%m-%d %H:%M:%S')"
        sleep 1
    done
) > "$FIFO" &

# --- 2. BSPWM Event Generator ---
(
    echo "B"
    bspc subscribe desktop | while read -r _; do
        echo "B"
    done
) > "$FIFO" &

# --- State Variables ---
CURRENT_WS=""
CURRENT_TIME=""

# --- Helper Function: Fetch & Format Workspaces ---
get_workspaces() {
    local workspaces=""
    
    # Get the ID of the globally focused desktop
    local focused_id
    focused_id=$(bspc query -D -d focused)
    
    # Loop through the IDs of all desktops on THIS monitor directly
    for ws_id in $(bspc query -D -m "$MONITOR"); do
        # Fetch the human-readable name for this specific ID to display it
        local ws_name
        ws_name=$(bspc query -D -d "$ws_id" --names)

        # Simply compare the loop ID to the focused ID
        if [ "$ws_id" = "$focused_id" ]; then
            # Focused workspace on this monitor: Swap colors
            workspaces+="%{R} $ws_name %{R}"
        else
            # Unfocused workspace on this monitor
            workspaces+=" $ws_name "
        fi
    done
    echo "$workspaces"
}

# --- Main Render Loop ---
while read -r line; do
    prefix="${line:0:1}"
    data="${line:2}"

    if [[ "$prefix" == "T" ]]; then
        CURRENT_TIME="$data"
    elif [[ "$prefix" == "B" ]]; then
        CURRENT_WS=$(get_workspaces)
    fi

    echo -e "%{l} %{A:poweroff:}\uf011%{A} %{A:reboot:}\uf021%{A} ${CURRENT_WS}%{r}%{A:systray:}[\uf063]%{A} ${CURRENT_TIME}"

done < "$FIFO" | lemonbar -p -g "x16++" -B "$BG" -F "$FG" -f "$FONT" -n "lemonbar_${monitor}" "$MONITOR" | while read -r event; do
    # This loop catches the output from lemonbar when a button is clicked
    if [ "${event}" = "systray" ]; then
        st_id=$(xdotool search --class stalonetray 2>/dev/null | head -n1)
        st_state=$(xprop -id "${st_id}" WM_STATE 2>/dev/null)

        # 0 = Normal state ; 1 = Other state
        st_normal=$( echo "${st_state}" | grep -q -i "normal" ; echo $? )

        if [ "${st_normal}" = "0" ]; then
            xdotool windowunmap "$st_id"
        else
            xdotool windowmap "$st_id"
        fi
    fi
    if [ "${event}" = "poweroff" ]; then
        sudo poweroff
    fi
    if [ "${event}" = "reboot" ]; then
        sudo reboot
    fi
done
