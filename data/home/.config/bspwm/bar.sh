#!/usr/bin/env bash

if [ -z "$1" ]; then
    for mon in $(bspc query -M --names); do
        bash "$0" "$mon" &
    done
    wait
    exit
fi

MONITOR="$1"

# --- Configuration ---
# lemonbar uses #AARRGGBB format.
BG="#88112244"
FG="#FF7788FF"

# Font configuration (Requires lemonbar to be compiled with XFT support)
FONT="Hack Nerd Font Mono:style=Bold:size=10"

# --- Setup Named Pipe (FIFO) ---
FIFO="/tmp/lemonbar_fifo_${MONITOR}_$$"
mkfifo "$FIFO"

trap 'rm -f "$FIFO"; kill $(jobs -p) 2>/dev/null' EXIT INT TERM

# --- 1. Clock Generator ---
(
    while true; do
        echo "T $(date '+%Y-%m-%d %H:%M:%S')"
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
            workspaces+="%{B${FG}}%{F${BG}} $ws_name %{F-}%{B-}"
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

    echo "%{l}${CURRENT_WS}%{r}${CURRENT_TIME} "
    
done < "$FIFO" | lemonbar -p -g "x16++" -B "$BG" -F "$FG" -f "$FONT" -n "lemonbar_${monitor}" "$MONITOR"
