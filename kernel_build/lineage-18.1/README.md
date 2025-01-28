# Build instructions

**You need at least 250 GB free space, SSD is strongly recommended. If free space is low, BTRFS can be used for transparent compression.**  
**ZRAM is recommended if less 16 GB RAM**

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
    mkdir lineage-18.1
    cd lineage-18.1
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.local/bin/repo
    chmod a+x ~/.local/bin/repo
    ```

2. Clone lineage vendor repo

    ```bash
    repo init -u https://github.com/LineageOS/android.git -b lineage-18.1 --git-lfs
    repo sync build/make
    ```

3. Get waydroid vendor manifest

    ```bash
    wget -O - https://raw.githubusercontent.com/waydroid/android_vendor_waydroid/lineage-18.1/manifest_scripts/generate-manifest.sh | bash
    ```

4. OpenGapps part 1

    If you don't want it, skip to step 5

    Add block in the file: ```nano .repo/manifests/default.xml``` before the </manifest> tag

    ```xml
    <remote name="opengapps" fetch="https://github.com/opengapps/"  />
    <remote name="opengapps-gitlab" fetch="https://gitlab.opengapps.org/opengapps/"  />

    <project path="vendor/opengapps/build" name="aosp_build" revision="master" remote="opengapps" />

    <project path="vendor/opengapps/sources/all" name="all" clone-depth="1" revision="master" remote="opengapps-gitlab" />
    <project path="vendor/opengapps/sources/x86_64" name="x86_64" clone-depth="1" revision="master" remote="opengapps-gitlab" />
    ```

    For arm add this instead of x86_64

    ```xml
    <!-- arm64 depends on arm -->
    <project path="vendor/opengapps/sources/arm" name="arm" clone-depth="1" revision="master" remote="opengapps-gitlab" />
    <project path="vendor/opengapps/sources/arm64" name="arm64" clone-depth="1" revision="master" remote="opengapps-gitlab" />
    ```

5. Sync repos

   About 130 gigabytes of data will be downloaded

    ```bash
    repo sync
    ```

6. OpenGapps part 2

    If you don't want it, skip to step 7

    Add line in the end of this file: ```nano device/waydroid/waydroid/device.mk```

    ```bash
    # GAPPS
    GAPPS_VARIANT := pico
    $(call inherit-product, vendor/opengapps/build/opengapps-packages.mk)
    ```

    or

    ```bash
    curl https://raw.githubusercontent.com/YogSottot/waydroid_stuff/master/kernel_build/lineage-18.1/0001-Add-opengapps-in-device.mk.patch | git -C device/waydroid/waydroid/ apply -v --index
    ```

    [Package Comparison](https://github.com/opengapps/opengapps/wiki/Package-Comparison)

    [fix opengapps build](https://github.com/opengapps/aosp_build/pull/222)

    ```bash
    curl https://github.com/cwhuang/aosp_build/commit/384cdac7930e7a2b67fd287cfae943fdaf7e5ca3.patch | git -C vendor/opengapps/build apply -v --index
    curl https://github.com/cwhuang/aosp_build/commit/3bb6f0804fe5d516b6b0bc68d8a45a2e57f147d5.patch | git -C vendor/opengapps/build apply -v --index
    ```

7. Apply waydroid patches

    ```bash
    . build/envsetup.sh
    apply-waydroid-patches
    ```

8. Apply custom patches

    If you don't need the patches, why are you building images? You can get official images via ```waydroid init -f -s GAPPS```.

    * Enable squashfs images [[PR](https://github.com/waydroid/android_device_waydroid_waydroid/pull/2)]

      ```bash
      curl https://raw.githubusercontent.com/YogSottot/waydroid_stuff/refs/heads/master/kernel_build/lineage-18.1/0001-Build-squashfs-images.patch | git -C device/waydroid/waydroid/ apply -v --index
      ```

    * Add force_mouse_as_touch option. [PR](https://github.com/waydroid/android_vendor_waydroid/pull/33)  
       If PR is already merged, this patch is no longer needed

        ```bash
        curl https://raw.githubusercontent.com/waydroid/android_vendor_waydroid/828afefb59ccce46e089756e95e15e6191e272f1/waydroid-patches/base-patches-30/frameworks/base/0051-Force-mouse-event-as-touch-1-2.patch | git -C frameworks/base/ apply -v --index
        curl https://raw.githubusercontent.com/waydroid/android_vendor_waydroid/828afefb59ccce46e089756e95e15e6191e272f1/waydroid-patches/base-patches-30/frameworks/native/0015-Force-mouse-event-as-touch-2-2.patch | git -C frameworks/native/ apply -v --index
        ```

    * Add xmlconfig [PR](https://github.com/waydroid/android_external_mesa3d/pull/8)  
        If PR is already merged, this patch is no longer needed

        ```bash
        curl https://raw.githubusercontent.com/YogSottot/waydroid_stuff/master/kernel_build/lineage-18.1/0001-patch-30-Enable-xmlconfig-on-Android-01.patch | git -C external/mesa/ apply -v --index
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

11. Build Docker image

    ```bash
    docker build -t waydroid-build-24.04 .
    ```

    Build arguments

    ```GIT_NAME```: Name to use for git commits. Default: "YogSottot"
    ```GIT_EMAIL```: Email to use for git commits. Default: "<7411302+YogSottot@users.noreply.github.com>"  
    ```PULL_REBASE```: Perform rebase instead of merge when pulling. Default: true

    You can pass build arguments to the build command like this:

    ```docker build -t waydroid-build-24.04 . --build-arg GIT_NAME="John Doe" --build-arg GIT_EMAIL="john@doe.com" .```

    If you want to use ccache, create a volume for it

    ```bash
    mkdir -p /mnt/ccache/lineage-18.1
    docker create -v /mnt/ccache/lineage-18.1:/ccache --name ccache-18.1 waydroid-build-24.04
    ```

12. Build system images

    ```bash
    docker run -e CCACHE_DIR=/ccache --volumes-from ccache-18.1 -v $(pwd):/mnt/lineage -it waydroid-build-24.04 bash -c 'cd /mnt/lineage && ccache -M 50G && . build/envsetup.sh && lunch lineage_waydroid_x86_64-userdebug && make systemimage -j$(nproc --all)' 
    ```

    If you need ```waydroid-arm64```, change ```lineage_waydroid_x86_64-userdebug``` to ```lineage_waydroid_arm64-userdebug```.  
    A full list of options is available at command ```lunch```.  

13. Build vendor image

    ```bash
    docker run -e CCACHE_DIR=/ccache --volumes-from ccache-18.1 -v $(pwd):/mnt/lineage -it waydroid-build-24.04 bash -c 'cd /mnt/lineage && ccache -M 50G && . build/envsetup.sh && lunch lineage_waydroid_x86_64-userdebug && make vendorimage -j$(nproc --all)' 
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
      * If you get the error: ```java.lanjava.lang.OutOfMemoryError: Java heap spaceg.OutOfMemoryError: Java heap space``` then do this:
        * Open file ```build/soong/java/droiddocdoc.go```
        * Go to line 1476
        * Add a new line with content ```Flag("-JXmx10g").```
        * This is how that part should look like:
        ```
        cmd.BuiltTool(ctx, "metalava").
		    Flag(config.JavacVmFlags).
		    Flag("-JXmx10g").
		    FlagWithArg("-encoding ", "UTF-8").
		    FlagWithArg("-source ", javaVersion.String()).
		    FlagWithRspFileInputList("@", srcs).
		    FlagWithInput("@", srcJarList)
        ```
    
    Also you can create both images with a single command:

    ```bash
    docker run -e CCACHE_DIR=/ccache --volumes-from ccache-18.1 -v $(pwd):/mnt/lineage -it waydroid-build-24.04 bash -c 'cd /mnt/lineage && ccache -M 50G && . build/envsetup.sh && lunch lineage_waydroid_x86_64-userdebug && make systemimage -j$(nproc --all) && make vendorimage -j$(nproc --all)' 
    ```

15. Convert images

    ```bash
    simg2img  out/target/product/waydroid_x86_64/system.img ./system.img
    simg2img  out/target/product/waydroid_x86_64/vendor.img ./vendor.img
    ```

    or

    ```bash
    docker run -v $(pwd):/mnt/lineage -it waydroid-build-24.04 bash -c 'cd /mnt/lineage && simg2img  out/target/product/waydroid_x86_64/system.img ./system.img && simg2img  out/target/product/waydroid_x86_64/vendor.img ./vendor.img'
    ```

16. Use images

    Make a backup beforehand

    ```bash
    rsync -a /var/lib/waydroid /opt/waydroid_backups/
    ```

    Your images are in current dir [lineage-18.1] (system.img / vendor.img)
    You can use rsync to copy images to /var/lib/waydroid/images  

    ```bash
    rsync *.img /var/lib/waydroid/images/
    ```
