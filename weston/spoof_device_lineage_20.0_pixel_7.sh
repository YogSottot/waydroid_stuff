#!/usr/bin/env bash
props=(
        "ro.product.brand = google"
        "ro.product.manufacturer = Google"
        "ro.product.device = cheetah"
        "ro.product.name = cheetah"
        "ro.system.build.product = cheetah"
        "ro.product.model = Pixel 7 Pro"
        "ro.system.build.flavor = cheetah-user"
        "ro.build.fingerprint = google/cheetah/cheetah:13/TQ3A.230901.001/10750268:user/release-keys"
        "ro.system.build.description = cheetah-user 13 TQ3A.230901.001 10750268 release-keys"
        "ro.bootimage.build.fingerprint = google/cheetah/cheetah:13/TQ3A.230901.001/10750268:user/release-keys"
        "ro.build.display.id = TQ3A.230901.001"
        "ro.build.tags = release-keys"
        "ro.build.description = cheetah-user 13 TQ3A.230901.001 10750268 release-keys"
        "ro.vendor.build.fingerprint = google/cheetah/cheetah:13/TQ3A.230901.001/10750268:user/release-keys"
        "ro.vendor.build.id = TQ3A.230901.001"
        "ro.vendor.build.tags = release-keys"
        "ro.vendor.build.type = user"
        "ro.odm.build.tags = release-keys"
        "ro.adb.secure = 1"
        "ro.debuggable = 0"
        "ro.build.selinux = 1"
)

for i in "${props[@]}";
        do echo $i >> /var/lib/waydroid/waydroid.cfg
done
waydroid upgrade --offline
