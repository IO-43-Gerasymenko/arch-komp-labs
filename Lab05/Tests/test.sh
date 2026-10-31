#!/bin/sh
set -eu
test "$(uname -m)" = armv7l
test "$(uname -r)" = 4.19.325-ak2
echo '=== Consumer without provider must fail ==='
dmesg -c > /dev/null
if insmod /mnt/host/lab05/hello2.ko; then
    echo 'FAIL: consumer loaded without provider'; exit 1
fi
dmesg -c
echo '=== Metadata ==='
modinfo /mnt/host/lab05/hello1.ko
modinfo /mnt/host/lab05/hello2.ko
echo '=== Default parameter ==='
insmod /mnt/host/lab05/hello1.ko
insmod /mnt/host/lab05/hello2.ko
test "$(cat /sys/module/hello2/parameters/count)" = 1
rmmod hello2
rmmod hello1
dmesg -c
for n in 0 1 2 3 4 5 6 7 8 9 10; do
    echo "=== count=$n ==="
    insmod /mnt/host/lab05/hello1.ko
    insmod /mnt/host/lab05/hello2.ko count="$n"
    test "$(cat /sys/module/hello2/parameters/count)" = "$n"
    if test "$n" = 3; then
        echo '=== Provider is in use by hello2 ==='
        rmmod hello1 || true
        test -d /sys/module/hello1
        test -d /sys/module/hello2
        lsmod
    fi
    rmmod hello2
    rmmod hello1
    messages=$(dmesg -c)
    printf '%s\n' "$messages"
    greetings=$(printf '%s\n' "$messages" | grep -c 'hello1: Hello, world!' || true)
    test "$greetings" = "$n"
    events=$(printf '%s\n' "$messages" | grep -c 'print duration ' || true)
    test "$events" = "$n"
    if test "$n" = 0 || test "$n" -ge 5; then
        printf '%s\n' "$messages" | grep 'hello2: unusual count='
    fi
done
echo '=== count=11 must fail ==='
insmod /mnt/host/lab05/hello1.ko
if insmod /mnt/host/lab05/hello2.ko count=11; then
    echo 'FAIL: invalid module loaded'; exit 1
fi
test ! -d /sys/module/hello2
rmmod hello1
dmesg -c
echo 'PASS: Lab05 symbol dependency, 0..10, rejection of 11, durations and cleanup'
