#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(dirname "$(realpath "${0}")")

# \/ remember that the prefixes must end with /
SYMLINK_REAL_PREFIX="/"
SYMLINK_REAL_HOME_PREFIX="${HOME}/"
SYMLINK_STORE_PREFIX="${SCRIPT_DIR}/data/"
SYMLINK_STORE_HOME_PREFIX="${SCRIPT_DIR}/data/home/"

declare -a files=(
)

declare -a home_files=(
".config/bspwm/bspwmrc"
".config/sxhkd/sxhkdrc"
".config/dunst/dunstrc"
".config/zed/settings.json"
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
".Xresources"
".Xdefaults"
)

# \/ remember that the folders must not end with / or /*
declare -a folders=(
)

declare -a home_folders=(
".nano"
)

symlink_path_ex () {
    real_path=${1}
    symlink_path=${2}
    folder=${3}
    if [ -e "${real_path}" ] && [ ! -L "${real_path}" ]; then
        mkdir -v -p "$(dirname "${symlink_path}")"
        if [ "${folder}" = '/*' ]; then  mkdir -v -p "${symlink_path}"; fi
        mv -v $( ls "${real_path}"${folder} 2>/dev/null ) "${symlink_path}" 2>/dev/null | :
        #rmdir "${real_path}"
        ln -v -sf "${symlink_path}" "${real_path}"
        echo "Moved and Linked: \"${real_path}\" to: \"${symlink_path}\""
    else
        if [ -e "${symlink_path}" ]; then
            mkdir -v -p "$(dirname "${real_path}")"
            #if [ "${folder}" = '/*' ]; then  mkdir -v -p "${real_path}"; fi
            ln -v -sf "${symlink_path}" "${real_path}"
            echo "Linked: \"${real_path}\" to: \"${symlink_path}\""
        else
            echo "ERROR: The path \"${real_path}\" and its symlink \"${symlink_path}\" do not exist!"
            exit 1
        fi
    fi
}

for i in "${!files[@]}"
do
    curr_file="${files[${i}]}"
    file_path="${SYMLINK_REAL_PREFIX}${curr_file}"
    symlink_path="${SYMLINK_STORE_PREFIX}${curr_file}"
    symlink_path_ex "${file_path}" "${symlink_path}" ''
done

for i in "${!home_files[@]}"
do
    curr_file="${home_files[${i}]}"
    file_path="${SYMLINK_REAL_HOME_PREFIX}${curr_file}"
    symlink_path="${SYMLINK_STORE_HOME_PREFIX}${curr_file}"
    symlink_path_ex "${file_path}" "${symlink_path}" ''
done

for i in "${!folders[@]}"
do
    curr_folder="${folders[${i}]}"
    folder_path="${SYMLINK_REAL_PREFIX}${curr_folder}"
    symlink_path="${SYMLINK_STORE_PREFIX}${curr_folder}"
    symlink_path_ex "${folder_path}" "${symlink_path}" '/*'
done

for i in "${!home_folders[@]}"
do
    curr_folder="${home_folders[${i}]}"
    folder_path="${SYMLINK_REAL_HOME_PREFIX}${curr_folder}"
    symlink_path="${SYMLINK_STORE_HOME_PREFIX}${curr_folder}"
    symlink_path_ex "${folder_path}" "${symlink_path}" '/*'
done
