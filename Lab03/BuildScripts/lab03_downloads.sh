#!/bin/bash
set -euo pipefail
cd /srv/ak2/Lab03/sources
mkdir -p ../logs
curl -fL --retry 1 --connect-timeout 10 --max-time 180 https://codeload.github.com/u-boot/u-boot/tar.gz/refs/tags/v2019.07 -o u-boot-2019.07.tar.gz
curl -fL --retry 1 --connect-timeout 10 --max-time 180 https://busybox.net/downloads/busybox-1.31.1.tar.bz2 -o busybox-1.31.1.tar.bz2
curl -fL --retry 1 --connect-timeout 10 --max-time 60 https://patchwork.ozlabs.org/series/130450/mbox/ -o u-boot-series-130450.mbox
file u-boot-2019.07.tar.gz busybox-1.31.1.tar.bz2 u-boot-series-130450.mbox
sha256sum u-boot-2019.07.tar.gz busybox-1.31.1.tar.bz2 u-boot-series-130450.mbox | tee ../logs/download-sha256.txt
tar -xzf u-boot-2019.07.tar.gz
tar -xjf busybox-1.31.1.tar.bz2
head -n 16 u-boot-series-130450.mbox
