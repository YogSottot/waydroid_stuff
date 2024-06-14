# weston

## Install Instructions for waydroid

<https://docs.waydro.id/usage/install-on-desktops#ubuntu-debian-and-derivatives>  

## Install weston

```bash
apt install -y weston 
```

Use ```waydroid.sh``` to run waydroid in weston in x11 session.  
Read the comments in the script, to activate the mantis gamepad.

## Clipboard

```bash
apt install -y wl-clipboard xclip
pip3 install pyclip --user
```

## ARM translation

<https://github.com/casualsnek/waydroid_script>  

```switch_arm.sh``` script for fast switching of translators.  
It is needed because some applications run on only one of them.  
Some applications work on libhoudini but don't work on libndk (example: Crusaders Quest, Sdorica)  
Some apps work on libndk but don't work on libhoudini (example: Tower of Fantasy, Mantis Gamepad Pro)  

```libhoudini_patch.sh``` and ```libndk_patch.sh``` script for patching libhoudini/libndk. (Fix Blue Archive Global and Wuthering Waves) Source: https://github.com/waydroid/waydroid/issues/788#issuecomment-2162386712

## Alternatives for  Mantis Gamepad  

### XTMapper

[Wayland-getevent option](https://github.com/Xtr126/wayland-getevent/blob/main/README.md)  
[Patched cage option](https://github.com/Xtr126/wayland-getevent/blob/main/README-alt.md)

Don't know if it work in x11-session.

## Basic setup

<https://docs.waydro.id/usage/waydroid-prop-options>

### Set the desired screen resolution

<https://toolstud.io/photo/aspect.php?width=1600&height=720&compare=video>  
<https://andrew.hedges.name/experiments/aspect_ratio/>  

```bash
waydroid prop set persist.waydroid.width 1890
waydroid prop set persist.waydroid.height 850
```

### Fix rotation

```bash
sudo waydroid shell wm set-fix-to-user-rotation enabled
```

### Fix some apps

```bash
sudo waydroid shell
chmod 777 -R /sdcard/Android
chmod 777 -R /data/media/0/Android
chmod 777 -R /sdcard/Android/data
chmod 777 -R /data/media/0/Android/obb
chmod 777 -R /mnt/*/*/*/*/Android/data
chmod 777 -R /mnt/*/*/*/*/Android/obb
```

### Set fake touch

For all (may break some functions in applications):

```bash
waydroid prop set persist.waydroid.fake_touch '*.*'
```

For some (string, 91 character limit):

```bash
waydroid prop set persist.waydroid.fake_touch com.HoYoverse.*,com.kakaogames.*,com.bluepoch.*,com.miHoYo.*,com.neowizgames.*
```

In some cases fake_touch [does not work](https://github.com/waydroid/waydroid/issues/954).  
You need images with the [mouse_force_touch patch](https://github.com/waydroid/android_vendor_waydroid/pull/33).  

To activate it, you need to execute the command:  

```bash
sudo waydroid shell settings put system force_mouse_as_touch 1
```

To deactivate, run the command:  

```bash
sudo waydroid shell settings put system force_mouse_as_touch 0
```

Or use script ```mouse_force_touch.sh 1``` / ```mouse_force_touch.sh 0```  

### For gamepads

(bool, default: false) Allow android direct access to hotplugged devices

```bash
waydroid prop set persist.waydroid.uevent true
```

For reconnect gamepad use script ```reset_pad.sh```

<https://github.com/waydroid/waydroid/issues/289#issuecomment-1531201899>  

Controller reconnections can be done by a command in the console or by a script, rather than by physically reconnecting the controller. This seems more convenient to me.  

```bash
echo 0 > /sys/bus/usb/devices/3-2/authorized
echo 1 > /sys/bus/usb/devices/3-2/authorized
3-2 should be replaced with your device number.
```

This is for a wired usb controller, of course  
To find out the device number, you need to look at vid|pid via lsusb  

Then run the command  

```bash
for X in /sys/bus/usb/devices/*; do 
    echo "$X"
    cat "$X/idVendor" 2>/dev/null 
    cat "$X/idProduct" 2>/dev/null
    echo
done
```

Or in case its not a wired USB device, you can recreate /dev/input/eventX by triggering the uevent  
Finding out the correct /dev/input/eventX by  
```cat /proc/bus/input/devices```
Assuming we got event4,
```sudo sh -c 'echo add > /sys/class/input/event4/uevent'```
This also requires the prop set beforehand, of course.

### For proxy

If you have proxy on 9000 port on host  
Forward port from host to waydroid  

```adb reverse tcp:9000 tcp:9000```

```bash
sudo waydroid shell settings put global http_proxy "127.0.0.1:9000" 
sudo waydroid shell settings put global https_proxy "127.0.0.1:9000" 
```

or without port forwarding  

```bash
sudo waydroid shell settings put global http_proxy "192.168.240.1:9000" 
sudo waydroid shell settings put global https_proxy "192.168.240.1:9000"
```

or proxy in the internet

```bash
sudo waydroid shell settings put global http_proxy "ip_addr:port" 
sudo waydroid shell settings put global https_proxy "ip_addr:port" 
sudo waydroid shell settings put global global_http_proxy_username login
sudo waydroid shell settings put global global_http_proxy_password "password"
```

check if it work:

```bash
sudo waydroid shell
curl https://ifconfig.me
```

Disable proxy  

```bash
sudo waydroid shell settings put global http_proxy :0
sudo waydroid shell settings put global https_proxy :0
```

### Logcat without garbage

```bash
sudo waydroid logcat | grep -vi controller | grep -vi mantis | grep -vi gamepad | grep -v lowmemorykiller | grep -v libprocessgroup
```
