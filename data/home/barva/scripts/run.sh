#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "${0}")")

export BARVA_SOURCE="$(${SCRIPT_DIR}/pa-get-default-monitor.sh)"
export BARVA_BG="#0a0c1088"
export BARVA_TARGET="#22006688"
export BARVA_FPS="144"

${SCRIPT_DIR}/../src/barva
