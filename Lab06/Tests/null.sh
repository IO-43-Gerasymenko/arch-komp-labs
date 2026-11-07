#!/bin/sh
set -u
test "$(uname -m)" = armv7l || exit 1
test "$(uname -r)" = 4.19.325-ak2 || exit 1
echo '=== Deliberate NULL allocation result at greeting 5 ==='
insmod /mnt/host/lab06/hello.ko count=5
echo "insmod exit status: $?"
echo '=== Module state after NULL dereference ==='
lsmod
cat /sys/module/hello/initstate
rmmod hello
echo "rmmod exit status: $?"
echo 'END: Lab06 NULL observation'
