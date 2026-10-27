#!/bin/sh
set -eu
test "$(uname -m)" = armv7l
test "$(uname -r)" = 4.19.325-ak2
echo '=== Teacher example, build system 1 ==='
insmod /mnt/host/example/hello.ko
rmmod hello
dmesg | tail -n 6
echo '=== Own module metadata ==='
modinfo /mnt/host/lab04/hello.ko
echo '=== Default parameter ==='
dmesg -c > /dev/null
insmod /mnt/host/lab04/hello.ko
test "$(cat /sys/module/hello/parameters/count)" = 1
rmmod hello
dmesg -c
for n in 0 1 2 3 4 5 6 7 8 9 10; do
    echo "=== count=$n ==="
    insmod /mnt/host/lab04/hello.ko count="$n"
    test "$(cat /sys/module/hello/parameters/count)" = "$n"
    rmmod hello
    messages=$(dmesg -c)
    printf '%s\n' "$messages"
    greetings=$(printf '%s\n' "$messages" | grep -c 'hello: Hello, world!' || true)
    test "$greetings" = "$n"
    events=$(printf '%s\n' "$messages" | grep -c 'hello: event ' || true)
    test "$events" = "$n"
    if test "$n" = 0 || test "$n" -ge 5; then
        printf '%s\n' "$messages" | grep 'hello: unusual count='
    fi
done
echo '=== count=11 must fail ==='
if insmod /mnt/host/lab04/hello.ko count=11; then
    echo 'FAIL: invalid module loaded'; exit 1
fi
test ! -d /sys/module/hello
dmesg -c
echo 'PASS: Lab04 default, 0..10, rejection of 11, timestamps and cleanup'
