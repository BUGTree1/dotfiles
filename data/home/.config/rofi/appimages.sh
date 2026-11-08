#!/usr/bin/env bash

APPDIR="$HOME/AppImages"
EXTRACT_DIR="$APPDIR/extracted"

if [ "$#" -eq 0 ]; then
    # --- PHASE 1: Extraction & Menu Generation (Called when Rofi queries the mode) ---
    mkdir -p "$EXTRACT_DIR"
    
    while IFS= read -r -d '' appimage; do
        filename=$(basename "$appimage")
        appname="${filename%.[aA][pP][pP][iI][mM][aA][gG][eE]}"
        target="$EXTRACT_DIR/$appname"

        if [ ! -d "$target" ] || [ "$appimage" -nt "$target" ]; then
            rm -rf "$EXTRACT_DIR/squashfs-root"
            cd "$EXTRACT_DIR" || exit
            chmod +x "$appimage"
            if "$appimage" --appimage-extract > /dev/null 2>&1; then
                rm -rf "$target"
                mv "$EXTRACT_DIR/squashfs-root" "$target"
            fi
        fi
    done < <(find "$APPDIR" -maxdepth 1 -iname "*.appimage" -print0)

    # Output items and icons to Rofi
    for dir in "$EXTRACT_DIR"/*/; do
        [ -d "$dir" ] || continue
        desktop_file=$(find "$dir" -maxdepth 2 -name "*.desktop" | head -n 1)
        
        if [ -n "$desktop_file" ]; then
            name=$(awk -F'=' '$1=="Name" {print $2; exit}' "$desktop_file" | tr -d '\r')
            [ -z "$name" ] && name=$(awk -F'=' '$1~/^Name\[/ {print $2; exit}' "$desktop_file" | tr -d '\r')
            icon_name=$(awk -F'=' '$1=="Icon" {print $2; exit}' "$desktop_file" | tr -d '\r')
            appname=$(basename "$dir")
            
            [ -z "$name" ] && name="$appname"
            
            icon_path=""
            if [ -n "$icon_name" ]; then
                if [[ "$icon_name" == /* ]] && [ -f "$icon_name" ]; then
                    icon_path="$icon_name"
                else
                    icon_path=$(find "$dir" -type f \( -name "$icon_name.png" -o -name "$icon_name.svg" -o -name "$icon_name.*" \) | head -n 1)
                fi
            fi
            [ -z "$icon_path" ] && icon_path=$(find "$dir" -type f \( -name "*.png" -o -name "*.svg" \) | head -n 1)
            
            if [ -n "$icon_path" ]; then
                printf "%s\0icon\x1f%s\n" "$name" "$icon_path"
            else
                printf "%s\n" "$name"
            fi
        fi
    done
else
    # --- PHASE 2: Execution (Called when an item is selected in Rofi) ---
    selected="$*"
    
    for dir in "$EXTRACT_DIR"/*/; do
        [ -d "$dir" ] || continue
        desktop_file=$(find "$dir" -maxdepth 2 -name "*.desktop" | head -n 1)
        if [ -n "$desktop_file" ]; then
            name=$(awk -F'=' '$1=="Name" {print $2; exit}' "$desktop_file" | tr -d '\r')
            [ -z "$name" ] && name=$(basename "$dir")
            
            if [ "$name" = "$selected" ]; then
                appname=$(basename "$dir")
                appimage_path=$(find "$APPDIR" -maxdepth 1 -iname "$appname.appimage" | head -n 1)
                if [ -f "$appimage_path" ]; then
                    nohup "$appimage_path" > /dev/null 2>&1 &
                    exit 0
                fi
            fi
        fi
    done
fi
