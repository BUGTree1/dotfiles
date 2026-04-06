#!/usr/bin/env bash

set -xe

#\/ remember that the prefixes must end with /
FILE_REAL_PREFIX="${HOME}/"
FILE_SYMLINK_PREFIX="${PWD}/data/"

declare -a files=(".config/zed/settings.json"
".config/alacritty/alacritty.toml"
".config/alacritty/github_dark_high_contrast.toml"
".config/plasmashellrc"
".bash_profile"
".bashrc"
".languagetool.cfg"
".nanorc"
".nvidia-settings-rc"
".profile"
".xinitrc"
".Xresources")

for i in "${!files[@]}"
do
    file_path="${FILE_REAL_PREFIX}${files[${i}]}"
    symlink_path="${FILE_SYMLINK_PREFIX}${files[${i}]}"
    if [ -f "${file_path}" ] && [ ! -L "${file_path}" ]; then
        mkdir -p "$(dirname "${symlink_path}")"
        mv -T "${file_path}" "${symlink_path}"
        ln -sf -T "${symlink_path}" "${file_path}"
    else
        if [ -f "${symlink_path}" ]; then
            mkdir -p "$(dirname "${file_path}")"
            ln -sf -T "${symlink_path}" "${file_path}"
        else
            echo "ERROR: The file \"${file_path}\" and its symlink \"${symlink_path}\" does not exist!"
        fi
    fi
done
