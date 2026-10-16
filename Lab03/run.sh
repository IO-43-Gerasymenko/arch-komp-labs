#!/bin/bash
set -euo pipefail
base=/srv/ak2/Lab03/sources
exec qemu-system-arm \
  -machine virt -cpu cortex-a15 -smp 2 -m 1024 -nographic -nic none \
  -kernel "$base/linux-4.19.325/arch/arm/boot/zImage" \
  -initrd "$base/busybox-1.31.1/rootfs.cpio.gz" \
  -append 'root=/dev/ram0 rw console=ttyAMA0,115200 mem=1024M' \
  -fsdev local,id=ak2share,path=/srv/ak2/qemu-share,security_model=none,readonly=on \
  -device virtio-9p-device,fsdev=ak2share,mount_tag=hostshare
