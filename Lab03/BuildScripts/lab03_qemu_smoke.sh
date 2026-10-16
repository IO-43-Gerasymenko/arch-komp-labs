#!/bin/bash
set -euo pipefail
LAB=/srv/ak2/Lab03
cat > "$LAB/run.sh" <<'EOF'
#!/bin/bash
set -euo pipefail
base=/srv/ak2/Lab03/sources
exec qemu-system-arm \
  -machine virt -cpu cortex-a15 -smp 2 -m 1024 -nographic -nic none \
  -kernel "$base/linux-4.19.325/arch/arm/boot/zImage" \
  -initrd "$base/busybox-1.31.1/rootfs.cpio.gz" \
  -append 'root=/dev/ram0 rw console=ttyAMA0,115200 mem=1024M' \
  -fsdev local,id=ak2share,path=/srv/ak2/qemu-share,security_model=none,readonly=on \
  -device virtio-9p-device,fsdev=ak2share,mount_tag=hostshare
EOF
chmod 755 "$LAB/run.sh"
ln -sfn Lab03 /srv/ak2/lab3
python3 - <<'PY'
import pexpect, time
with open('/srv/ak2/Lab03/logs/qemu-boot-verified.log', 'w') as log:
    log.write(time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())+'\n')
    child=pexpect.spawn('/srv/ak2/Lab03/run.sh', encoding='utf-8', codec_errors='replace', timeout=120)
    child.logfile=log
    try:
        child.expect('Please press Enter to activate this console')
        child.sendline('')
        child.expect(r'/ # ')
        for command in ['uname -a', 'cat /proc/version', 'busybox | head -n 3', 'ls /boot', 'mount -t 9p -o trans=virtio hostshare /mnt/host', 'mount', 'ls /lib/modules', 'poweroff -f']:
            child.sendline(command)
            if command.startswith('poweroff'): child.expect(pexpect.EOF)
            else:
                child.expect(r'/ # ')
                assert 'mounting hostshare' not in child.before
    finally:
        if child.isalive(): child.terminate(force=True)
print('QEMU smoke test finished')
PY
