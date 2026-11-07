#!/bin/sh
test "$(uname -m)" = armv7l || exit 1
dmesg | grep -E 'kernel BUG|Unable to handle|Internal error|PC is at|pc :|r4 :|Code:'
lsmod
cat /sys/module/hello/initstate
rmmod hello
