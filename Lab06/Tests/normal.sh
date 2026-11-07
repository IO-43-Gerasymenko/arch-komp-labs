#!/bin/sh
set -eu
test "$(uname -m)" = armv7l
test "$(uname -r)" = 4.19.325-ak2
insmod /mnt/host/lab06/hello.ko count=2
echo '=== Module section load addresses ==='
ls -a /sys/module/hello/sections
cat /sys/module/hello/sections/.text.unlikely
cat /sys/module/hello/sections/.init.text
echo '=== debugfs mount ==='
mount | grep debugfs
cat /sys/module/hello/parameters/count
rmmod hello
dmesg | tail -n 8
echo 'PASS: Lab06 normal path and section addresses'
