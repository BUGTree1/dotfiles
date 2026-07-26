#!/usr/bin/env bash

PREV_DIR="$(pwd)"
cd ../src ; make -B ; cd "$PREV_DIR"
