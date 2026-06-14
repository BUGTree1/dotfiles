#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source ~/.profile

if [[ -n "${ZED_TERM}" ]]; then
    CURRENT_DIR=$(pwd)
    PROJECT_NAME=$(basename "${CURRENT_DIR}")
    ZED_HISTORY_DIR="${HOME}/.config/zed/history/$PROJECT_NAME"
    mkdir -p "${ZED_HISTORY_DIR}"
    export HISTFILE="${ZED_HISTORY_DIR}/.bash_history"
    export HISTSIZE=100
    export HISTFILESIZE=100
    export PROMPT_COMMAND="history -a"
    shopt -s histappend
fi

clear
