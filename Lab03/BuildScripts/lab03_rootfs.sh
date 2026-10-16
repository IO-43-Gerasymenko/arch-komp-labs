#!/bin/bash
set -euo pipefail
LAB=/srv/ak2/Lab03
KERNEL=$LAB/sources/linux-4.19.325
BUSYBOX=$LAB/sources/busybox-1.31.1
ROOTFS=$BUSYBOX/_install
LINUXTC=/opt/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-
mkdir -p "$ROOTFS"/{boot,dev,etc/init.d,lib,proc,root,sys/kernel/debug,tmp,mnt/host}
cp "$KERNEL/arch/arm/boot/zImage" "$KERNEL/arch/arm/boot/dts/am335x-boneblack.dtb" "$KERNEL/System.map" "$ROOTFS/boot/"
cp "$KERNEL/.config" "$ROOTFS/boot/config"
make -C "$KERNEL" ARCH=arm CROSS_COMPILE=/opt/gcc-arm-10.3-2021.07-x86_64-arm-none-eabi/bin/arm-none-eabi- INSTALL_MOD_PATH="$ROOTFS" INSTALL_MOD_STRIP=1 modules_install > "$LAB/logs/modules-install.log" 2>&1
libc_dir=$("${LINUXTC}gcc" -print-sysroot)/lib
cp -a "$libc_dir/"*.so* "$ROOTFS/lib/"
cat > "$ROOTFS/etc/init.d/rcS" <<'EOF'
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
mount -t debugfs none /sys/kernel/debug
mkdir -p /dev/pts
mount -t devpts none /dev/pts
echo /sbin/mdev > /proc/sys/kernel/hotplug
mdev -s
hostname Ubuntu24
echo 'AK2 ARM laboratory: mishanya123'
EOF
chmod 755 "$ROOTFS/etc/init.d/rcS"
ln -sfn bin/busybox "$ROOTFS/init"
printf '%s\n' '$MODALIAS=.* root:root 660 @modprobe "$MODALIAS"' > "$ROOTFS/etc/mdev.conf"
printf '%s\n' 'root:x:0:' > "$ROOTFS/etc/group"
printf '%s\n' 'root:x:0:0:root:/root:/bin/sh' > "$ROOTFS/etc/passwd"
printf '%s\n' 'root::10933:0:99999:7:::' > "$ROOTFS/etc/shadow"
chmod 600 "$ROOTFS/etc/shadow"
printf '%s\n' 'nameserver 8.8.8.8' > "$ROOTFS/etc/resolv.conf"
cat > "$ROOTFS/etc/inittab" <<'EOF'
::sysinit:/etc/init.d/rcS
::askfirst:/bin/sh
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
EOF
printf '%s\n' 'export PS1="[arm-qemu:\w]# "' > "$ROOTFS/etc/profile"
mkdir -p /srv/ak2/qemu-share
du -sh "$ROOTFS"
"${LINUXTC}readelf" -l "$ROOTFS/bin/busybox" | grep interpreter
grep -E 'CONFIG_(9P_FS|NET_9P|VIRTIO|DEVTMPFS|MODULES|THUMB2_KERNEL|BUG|DEBUG_INFO)=' "$KERNEL/.config"
