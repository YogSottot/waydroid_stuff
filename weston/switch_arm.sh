#!/usr/bin/env bash
set -eo pipefail

# The script automatically detects which translator is currently installed and changes it to the second one

# put in /etc/sudoers.d/waydroid
# username ALL=NOPASSWD: /usr/bin/python3 main.py install libhoudini
# username ALL=NOPASSWD: /usr/bin/python3 main.py install libndk
# username ALL=NOPASSWD: /usr/bin/python3 main.py remove libndk
# username ALL=NOPASSWD: /usr/bin/python3 main.py remove libhoudini


if [ -f /var/lib/waydroid/overlay/system/lib64/libndk_translation.so ]; then
	echo Currently installed: libndk
	current_arm="libndk"
	new_arm="libhoudini"
fi

if [ -f /var/lib/waydroid/overlay/system/lib64/libhoudini.so ]; then
	echo Currently installed: libhoudini
	current_arm="libhoudini"
	new_arm="libndk"
fi

if [ -z ${current_arm} ]; then
	echo Arm-translator not installed. Use https://github.com/casualsnek/waydroid_script#install-libndk-arm-translation
	exit
fi

cd /path/to/casualsnek/waydroid_script
echo Removing: ${current_arm}
sudo /usr/bin/python3 main.py remove ${current_arm}
echo Installing: ${new_arm}
sudo /usr/bin/python3 main.py install ${new_arm}
