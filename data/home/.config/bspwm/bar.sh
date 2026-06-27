#!/usr/bin/env bash

# Kill existing lemonbar instances to prevent overlapping bars on restart
killall lemonbar 2>/dev/null

# --- Color Configuration ---
# lemonbar uses #AARRGGBB format.
BG_COLOR="#88112244"   # x% transparent "black"
FG_COLOR="#FF7788FF"   # 100% opaque white

# Font configuration (Requires lemonbar to be compiled with XFT support)
FONT="Hack Nerd Font Mono:style=Bold:size=10"

# --- Workspace Parsing Function ---
get_workspaces() {
    local monitor=$1
    local output=""
    
    # Get the focused desktop specifically for THIS monitor.
    # The -m restricts to the monitor, and -d focused gets the active one on it.
    local focused_ws=$(bspc query -D --names -m "$monitor" -d '.focused' 2>/dev/null)
    
    # Get all desktops for THIS monitor
    for ws in $(bspc query -D --names -m "$monitor" 2>/dev/null); do
        if [ "$ws" == "$focused_ws" ]; then
            # %{R} swaps the current foreground and background colors
            # %{A...:} makes the workspace clickable to switch to it
            output+="%{R}%{A1:bspc desktop -f $ws:} $ws %{A}%{R}"
        else
            output+="%{A1:bspc desktop -f $ws:} $ws %{A}"
        fi
    done
    
    echo "$output"
}

# --- Bar Spawning Function ---
spawn_bar() {
    local monitor=$1
    
    # This loop runs in the background for each monitor
    while true; do
        workspaces=$(get_workspaces "$monitor")
        clock=$(date '+%Y-%m-%d %H:%M:%S')
        
        # %{l} aligns the following text to the left
        # %{r} aligns the following text to the right
        # Added some padding spaces for aesthetics
        echo "%{l}   ${workspaces}%{r}${clock}   "
        
        # Refresh every 1 second
        sleep 1
    done | lemonbar -g "x16++" -B "$BG_COLOR" -F "$FG_COLOR" -f "$FONT" -n "lemonbar_${monitor}" "$monitor" | sh
}

# --- Main Execution ---

# Get an array of all currently connected monitor names
MONITORS=($(bspc query -M --names))

# Spawn a separate bar instance for each monitor
for mon in "${MONITORS[@]}"; do
    spawn_bar "$mon" &
done

# Wait for all background bar processes to keep the script alive
wait
