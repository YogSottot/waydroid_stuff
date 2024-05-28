#!/usr/bin/env bash
set -xeuo pipefail

killall -9 weston || true;
sudo systemctl restart waydroid-container.service;

if ! pgrep weston; then
    # weston --socket=/run/user/1000/waydroid.socket &> /dev/null &
    # to copy-paste work
    weston &> /dev/null &
    PID1=$!
fi
sleep 2;
#export WAYLAND_DISPLAY=waydroid.socket
waydroid show-full-ui &
sleep 20

## if use gamepad, then uncomment
# sudo ~/.local/bin/reset_pad.sh &
# sleep 1

## if use mantis gamepad pro, then uncomment
# sudo waydroid shell sh /sdcard/Android/data/app.mantispro.gamepad/files/buddyNew.sh &
# sudo waydroid shell ime disable app.mantispro.gamepad/.services.MainService &
# sudo waydroid shell am force-stop app.mantispro.gamepad &

# disable usb-debug for some games
# sudo waydroid shell settings put global adb_enabled 0 &

## if use QtScrcpy, then uncomment
# ~/.local/bin/qtscrpy.sh

wait $PID1 # comment this line if use QtScrcpy instead of weston window
waydroid session stop ;
sudo systemctl stop waydroid-container.service ;
killall -9 weston || true;

# if you don't like waydroid in menu
rm -f ~/.local/share/applications/waydroid.*
rm -f ~/.local/share/applications/Waydroid.desktop

#rm -rf /run/user/1000/waydroid.socket
rm -rf /run/user/1000/wayland-0*

# fix konsole input
stty sane
