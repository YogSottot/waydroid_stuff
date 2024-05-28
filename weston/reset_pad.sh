#!/usr/bin/env bash
echo 0 > /sys/bus/usb/devices/3-2/authorized
sleep 3
echo 1 > /sys/bus/usb/devices/3-2/authorized

# find device
#for X in /sys/bus/usb/devices/*; do 
#    echo "$X"
#    cat "$X/idVendor" 2>/dev/null 
#    cat "$X/idProduct" 2>/dev/null
#    echo
#done

# Or in case its not a wired USB device, you can recreate /dev/input/eventX by triggering the uevent
# Finding out the correct /dev/input/eventX by
# cat /proc/bus/input/devices
# Assuming we got event4,
# sudo sh -c 'echo add > /sys/class/input/event4/uevent'
# This also requires the prop set beforehand, of course.
