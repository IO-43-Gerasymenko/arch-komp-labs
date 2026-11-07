#!/bin/bash
set -euo pipefail
cd /srv/ak2/Lab06/source
tc=/opt/gcc-arm-10.3-2021.07-x86_64-arm-none-eabi/bin/arm-none-eabi-
"${tc}objdump" -d -j .text.unlikely hello.ko.unstripped
"${tc}addr2line" -e hello.ko.unstripped -j .text.unlikely -f -i 0x14
"${tc}addr2line" -e hello.ko.unstripped -j .init.text -f -i 0x18
