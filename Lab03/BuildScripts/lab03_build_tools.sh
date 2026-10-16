#!/bin/bash
set -euo pipefail
cd /srv/ak2/Lab03/sources/u-boot-2019.07
python3 - <<'PY' > ../../logs/uboot-patch.log 2>&1
import mailbox, subprocess
for message in mailbox.mbox('../u-boot-series-130450.mbox'):
    payload = message.get_payload(decode=True)
    print(message['Subject'], flush=True)
    subprocess.run(['patch', '--batch', '--dry-run', '-p1'], input=payload, check=True)
    subprocess.run(['patch', '--batch', '-p1'], input=payload, check=True)
PY
export ARCH=arm
export CCACHE_DIR=/srv/ak2/Lab03/ccache
export CROSS_COMPILE='ccache /opt/gcc-arm-10.3-2021.07-x86_64-arm-none-eabi/bin/arm-none-eabi-'
make am335x_boneblack_defconfig > ../../logs/uboot-config.log 2>&1
/usr/bin/time -v make -j6 > ../../logs/uboot-build.log 2>&1
file MLO u-boot.img
sha256sum MLO u-boot.img
cd ../busybox-1.31.1
export CROSS_COMPILE='ccache /opt/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-'
make defconfig > ../../logs/busybox-config.log 2>&1
/usr/bin/time -v make -j6 > ../../logs/busybox-build.log 2>&1
make install > ../../logs/busybox-install.log 2>&1
file _install/bin/busybox
/opt/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-readelf -d _install/bin/busybox | grep NEEDED
