#!/bin/sh
set -u
test "$(uname -m)" = armv7l || exit 1
test "$(uname -r)" = 4.19.325-ak2 || exit 1
echo '=== Deliberate BUG_ON for count=11 in disposable ARM QEMU ==='
insmod /mnt/host/lab06/hello.ko count=11
echo "insmod exit status: $?"
echo '=== Module state after BUG ==='
lsmod
cat /sys/module/hello/initstate
rmmod hello
echo "rmmod exit status: $?"
echo 'END: Lab06 BUG_ON observation'
