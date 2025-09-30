#!/usr/bin/env bash
props=(
        "ro.product.brand = google"
        "ro.product.manufacturer = Google"
        "ro.system.build.product = redfin"
        "ro.product.name = redfin"
        "ro.product.device = redfin"
        "ro.product.model = Pixel 5"
        "ro.system.build.flavor = redfin-user"
        "ro.build.fingerprint = google/redfin/redfin:13/TQ3A.230901.001/10750268:user/release-keys"
        "ro.system.build.description = redfin-user 13 TQ3A.230901.001 10750268 release-keys"
        "ro.bootimage.build.fingerprint = google/redfin/redfin:13/TQ3A.230901.001/10750268:user/release-keys"
        "ro.build.display.id = TQ3A.230901.001"
        "ro.build.tags = release-keys"
        "ro.build.description = redfin-user 13 TQ3A.230901.001 10750268 release-keys"
        "ro.vendor.build.fingerprint = google/redfin/redfin:13/TQ3A.230901.001/10750268:user/release-keys"
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
