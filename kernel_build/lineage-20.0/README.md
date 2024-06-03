# Build instructions

**You need at least 250 Gb free space on ssd.**  
**Zram is recommended if less 16 Gb RAM**

```bash
apt install -y zram-tools
find /etc/default/zramswap -type f -print0 | xargs -0 sed -i 's/.*PERCENT=.*/PERCENT=100/g'
systemctl restart zramswap.service
```

Based on official instruction from [waydroid docs](https://docs.waydro.id/development/compile-waydroid-lineage-os-based-images) and [lineageos wiki](https://wiki.lineageos.org/emulator)  

Also used [aosp_build](https://github.com/opengapps/aosp_build) for lineage 18.1 kernel and [MindTheGapps](https://gitlab.com/MindTheGapps/vendor_gapps/) for lineage 20.0  

1. Prepare for build

    ```bash
    git lfs install
    git config --global trailer.changeid.key "Change-Id"
    mkdir lineage-20.0
    cd lineage-20.0
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.local/bin/repo
    chmod a+x ~/.local/bin/repo
    ```

2. Clone lineage vendor repo

    ```bash
    repo init -u https://github.com/LineageOS/android.git -b lineage-20.0 --git-lfs
    repo sync build/make
    ```

3. Get waydroid vendor manifest

    ```bash
    wget -O - https://raw.githubusercontent.com/waydroid/android_vendor_waydroid/lineage-20/manifest_scripts/generate-manifest.sh | bash
    ```

4. Mindthegapps part 1

    If you don't want it, skip to step 5

    Add block in the file: ```nano .repo/manifests/default.xml``` before the </manifest> tag

    ```xml
    <remote name="MindTheGapps" fetch="https://gitlab.com/MindTheGapps/" />
    <project path="vendor/gapps" name="vendor_gapps" remote="MindTheGapps" revision="tau" />
    ```

    Correspondence of android version and branch name can be found in  [```build/gapps.sh```](https://gitlab.com/MindTheGapps/vendor_gapps/-/blob/tau/build/gapps.sh?ref_type=heads). Switch branches until you find the right version.  
    Android 13 is tau branch

5. Sync repos

   About 200 gigabytes of data will be downloaded

    ```bash
    repo sync
    ```

6. Mindthegapps part 2

    If you don't want it, skip to step 7

    Add line in the end of this file: ```nano device/waydroid/waydroid/device.mk```

    For x86_64:

    ```bash
    include vendor/gapps/x86_64/x86_64-vendor.mk
    ```

    For arm64:

    ```bash
    include vendor/gapps/arm64/arm64-vendor.mk
    ```

    Add line in the end of this file: ```nano device/waydroid/waydroid/BoardConfig.mk```

    ```bash
    BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
    ```

7. Apply waydroid patches

    ```bash
    . build/envsetup.sh
    apply-waydroid-patches
    ```

8. Apply custom patches

    * **Only x86_64**: BoardConfig: Reland scudo native allocator for x86 devices [[PR](https://github.com/waydroid/android_device_waydroid_waydroid/pull/4)]

      ```bash
      curl https://patch-diff.githubusercontent.com/raw/waydroid/android_device_waydroid_waydroid/pull/4.patch | git -C device/waydroid/waydroid/ apply -v --index
      ```

    * **[Don't use the patch is broken on lineage-20!]** Add force_mouse_as_touch option. [PR](https://github.com/waydroid/android_vendor_waydroid/pull/33)  
       If PR is already merged, this patch is no longer needed

        ```bash
        curl https://raw.githubusercontent.com/YogSottot/waydroid_stuff/master/kernel_build/lineage-20.0/0001-patch-33-Force-mouse-event-as-touch-1-2.patch | git -C frameworks/base/ apply -v --index
        curl https://raw.githubusercontent.com/YogSottot/waydroid_stuff/master/kernel_build/lineage-20.0/0001-patch-33-Force-mouse-event-as-touch-2-2.patch | git -C frameworks/native/ apply -v --index
        ```

    * Add xmlconfig [PR](https://github.com/waydroid/android_external_mesa3d/pull/8)  
        If PR is already merged, this patch is no longer needed

        ```bash
        curl https://raw.githubusercontent.com/YogSottot/waydroid_stuff/master/kernel_build/lineage-20.0/0001-patch-33-Enable-xmlconfig-on-Android.patch | git -C external/mesa/ apply -v --index
        curl https://raw.githubusercontent.com/YogSottot/waydroid_stuff/master/kernel_build/lineage-18.1/0001-patch-30-Enable-xmlconfig-on-Android-02.patch | git -C device/waydroid/waydroid/ apply -v
        ```

9. Install docker
    [Documentation](https://docs.docker.com/desktop/install/linux-install/)  

    Of course you can build images without a docker. The [Dockerfile](../Dockerfile) has a list of required dependencies.

10. Copy Dockerfile

    ```bash
    wget https://raw.githubusercontent.com/YogSottot/waydroid_stuff/master/kernel_build/Dockerfile
    ```

    Dockerfile [based on this](https://github.com/rabilrbl/kernel-build/)

11. Build Docker imagekernel

    ```bash
    docker build -t waydroid-build-24.04 .
    ```

    Build arguments

    ```GIT_NAME```: Name to use for git commits. Default: "YogSottot"
    ```GIT_EMAIL```: Email to use for git commits. Default: "<7411302+YogSottot@users.noreply.github.com>"  
    ```PULL_REBASE```: Perform rebase instead of merge when pulling. Default: true

    You can pass build arguments to the build command like this:

    ```docker build -t waydroid-build-24.04 . --build-arg GIT_NAME="John Doe" --build-arg GIT_EMAIL="john@doe.com" .```

    If you want to use ccache, the create volume for it

    ```bash
    mkdir -p /mnt/ccache/lineage-20.0
    docker create -v /mnt/ccache/lineage-20.0:/ccache --name ccache-20.0 waydroid-build-24.04
    ```

12. Build system images

    ```bash
    docker run -e CCACHE_DIR=/ccache --volumes-from ccache-20.0 -v $(pwd):/mnt/lineage -it waydroid-build-24.04 bash -c 'cd /mnt/lineage && ccache -M 50G && . build/envsetup.sh && lunch lineage_waydroid_x86_64-userdebug && make systemimage -j$(nproc --all)' 
    ```

    If you need ```waydroid-arm64```, change ```lineage_waydroid_x86_64-userdebug``` to ```lineage_waydroid_arm64-userdebug```.  
    A full list of options is available at command ```lunch```.  

13. Build vendor image

    ```bash
    docker run -e CCACHE_DIR=/ccache --volumes-from ccache-20.0 -v $(pwd):/mnt/lineage -it waydroid-build-24.04 bash -c 'cd /mnt/lineage && ccache -M 50G && . build/envsetup.sh && lunch lineage_waydroid_x86_64-userdebug && make vendorimage -j$(nproc --all)' 
    ```

      * If you get the error: ```/bin/bash: line 1: out/soong/.intermediates/prebuilts/build-tools/m4/linux_glibc_x86_64/m4: No such file or directory``` then do this:

        ```bash
        cd out/soong/.intermediates/prebuilts/build-tools/m4/linux_glibc_x86_64/
        ln -sf ../../../../../../../prebuilts/build-tools/linux-x86/bin/m4 .
        cd ../../../../../../../
        ```

      * If you get the error: ```../subprojects/libarchive-3.7.2/libarchive/archive.h:101:10: fatal error: 'android_lf.h' file not found``` then do this [[PR](https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/27648)]:

        ```bash
        curl https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/27648.patch | git -C external/mesa/ apply -v --index
        ```

        or

        ```bash
        rm -f external/mesa/subprojects/libarchive.wrap
        ```

      * If you get the error: ```xmllint.c:45:10: fatal error: 'readline/readline.h' file not found``` then do this:

        ```bash
        rm -f external/mesa/subprojects/libxml2.wrap
        ```

    Also you can create both images with a single command:

    ```bash
    docker run -e CCACHE_DIR=/ccache --volumes-from ccache-20.0 -v $(pwd):/mnt/lineage -it waydroid-build-24.04 bash -c 'cd /mnt/lineage && ccache -M 50G && . build/envsetup.sh && lunch lineage_waydroid_x86_64-userdebug && make systemimage -j$(nproc --all) && make vendorimage -j$(nproc --all)' 
    ```

14. Convert images

    ```bash
    simg2img  out/target/product/waydroid_x86_64/system.img ./system.img
    simg2img  out/target/product/waydroid_x86_64/vendor.img ./vendor.img
    ```

    or

    ```bash
    docker run -v $(pwd):/mnt/lineage -it waydroid-build-24.04 bash -c 'cd /mnt/lineage && simg2img  out/target/product/waydroid_x86_64/system.img ./system.img && simg2img  out/target/product/waydroid_x86_64/vendor.img ./vendor.img'
    ```

15. Use images

    Make a backup of old images beforehand

    ```bash
    rsync -a /var/lib/waydroid /opt/waydroid_backups/
    ```

    If you updated from lineage-18.1, then make a backup of user-dir

    ```bash
    sudo rsync -a /home/user/.local/share/waydroid /home/user/.local/share/waydroid-18.1
    ```

    Your images are in current dir [lineage-20.0] (system.img / vendor.img)
    You can use rsync to copy images to /var/lib/waydroid/images  

    ```bash
    rsync *.img /var/lib/waydroid/images/
    ```

    If you installed the arm translator for android 11, you need to uninstall it and install the version for 13.  
    [casualsnek/waydroid_script](https://github.com/casualsnek/waydroid_script) can do that for you.
