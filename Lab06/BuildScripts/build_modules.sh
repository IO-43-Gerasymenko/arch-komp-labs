#!/bin/bash
set -euo pipefail
export ARCH=arm
export CROSS_COMPILE=/opt/gcc-arm-10.3-2021.07-x86_64-arm-none-eabi/bin/arm-none-eabi-
export KDIR=/srv/ak2/Lab03/sources/linux-4.19.325
for lab in 04 05 06; do
  mkdir -p /srv/ak2/Lab$lab/logs
  cd /srv/ak2/Lab$lab/source
  make -j6 > ../logs/build.log 2>&1
  find . -name '*.c' ! -name '*.mod.c' -print0 | xargs -0 "$KDIR/scripts/checkpatch.pl" --no-tree -f > ../logs/checkpatch.log 2>&1 || true
  cat ../logs/checkpatch.log
  if grep -Eq '^ERROR:' ../logs/checkpatch.log; then exit 1; fi
  mkdir -p /srv/ak2/qemu-share/lab$lab
  cp *.ko /srv/ak2/qemu-share/lab$lab/
  file *.ko
  sha256sum *.c *.ko Makefile
done
cd /srv/ak2/Lab04/example
make > ../logs/example-build.log 2>&1
mkdir -p /srv/ak2/qemu-share/example
cp hello.ko /srv/ak2/qemu-share/example/
