#!/usr/bin/env bash
set -eo pipefail

# QtScrcpy need usb-debug for work
sudo waydroid shell settings put global adb_enabled 1 &

CUR_DIR=$(pwd)
cd ~/Games/android/QtScrcpy
./QtScrcpy
cd "$CUR_DIR";
