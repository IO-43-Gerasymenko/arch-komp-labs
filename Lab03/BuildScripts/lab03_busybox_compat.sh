#!/bin/bash
set -euo pipefail
cd /srv/ak2/Lab03/sources/busybox-1.31.1
# Backport upstream d3539be8, retaining the older bb_perror_msg names.
python3 - <<'PY'
from pathlib import Path
import difflib, subprocess
changes = {
 'coreutils/date.c': [
  ('\tlocaltime_r(&ts.tv_sec, &tm_time);', '#if !ENABLE_FEATURE_DATE_NANO\n\tts.tv_nsec = 0;\n#endif\n\tlocaltime_r(&ts.tv_sec, &tm_time);'),
  ('\t\tts.tv_sec = validate_tm_time(date_str, &tm_time);', '\t\tts.tv_sec = validate_tm_time(date_str, &tm_time);\n\t\tts.tv_nsec = 0;'),
  ('stime(&ts.tv_sec)', 'clock_settime(CLOCK_REALTIME, &ts)')
 ],
 'util-linux/rdate.c': [
  ('\t\telse\n\t\t\tif (stime(&remote_time) < 0)\n\t\t\t\tbb_perror_msg_and_die("can\'t set time of day");', '\t\telse {\n\t\t\tstruct timespec ts;\n\n\t\t\tts.tv_sec = remote_time;\n\t\t\tts.tv_nsec = 0;\n\t\t\tif (clock_settime(CLOCK_REALTIME, &ts) < 0)\n\t\t\t\tbb_perror_msg_and_die("can\'t set time of day");\n\t\t}')
 ],
 'libbb/missing_syscalls.c': [
  ('int stime(const time_t *t)\n{\n\tstruct timeval tv;\n\ttv.tv_sec = *t;\n\ttv.tv_usec = 0;\n\treturn settimeofday(&tv, NULL);\n}\n\n', '')
 ]
}
patch = ''
for name, replacements in changes.items():
 old = Path(name).read_text(); new = old
 for before, after in replacements:
  assert new.count(before) == 1, (name, before)
  new = new.replace(before, after)
 patch += ''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='a/'+name,tofile='b/'+name))
Path('../busybox-1.31.1-stime-backport.patch').write_text(patch)
subprocess.run(['patch','--batch','--dry-run','-p1'], input=patch,text=True,check=True)
subprocess.run(['patch','--batch','-p1'], input=patch,text=True,check=True)
PY
export ARCH=arm
export CCACHE_DIR=/srv/ak2/Lab03/ccache
export CROSS_COMPILE='ccache /opt/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-'
/usr/bin/time -v make -j6 > ../../logs/busybox-build-fixed.log 2>&1
make install > ../../logs/busybox-install.log 2>&1
file _install/bin/busybox
/opt/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-readelf -d _install/bin/busybox | grep NEEDED
