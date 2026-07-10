#!/bin/sh
set -u

echo "===== System ====="
uname -a
echo

echo "===== Integrated kernel BTF ====="
if [ -r /sys/kernel/btf/vmlinux ]; then
    ls -lh /sys/kernel/btf/vmlinux
    echo "BTF_OK"
else
    echo "BTF_MISSING"
fi
echo

echo "===== Kernel requirements ====="
CFG=""
if [ -r /proc/config.gz ]; then
    CFG="zcat /proc/config.gz"
elif [ -r "/boot/config-$(uname -r)" ]; then
    CFG="cat /boot/config-$(uname -r)"
fi

if [ -n "$CFG" ]; then
    sh -c "$CFG" | grep -E \
      'CONFIG_(DEBUG_INFO|DEBUG_INFO_BTF|KPROBES|KPROBE_EVENTS|BPF|BPF_SYSCALL|BPF_JIT|BPF_STREAM_PARSER|NET_CLS_ACT|NET_SCH_INGRESS|NET_INGRESS|NET_EGRESS|NET_CLS_BPF|BPF_EVENTS|CGROUPS|XDP_SOCKETS)=' \
      || true
else
    echo "Kernel config is not exposed; use BTF/module checks below."
fi
echo

echo "===== DAE packages ====="
opkg list-installed 2>/dev/null | grep -E '^(dae|luci-app-daede|kmod-sched-bpf|kmod-veth|v2ray-geo)' || true
echo

echo "===== Modules ====="
find /lib/modules/"$(uname -r)" -type f 2>/dev/null | grep -E '(sched.*bpf|veth|xdp)' || true
echo

echo "===== DAE binary ====="
if command -v dae >/dev/null 2>&1; then
    dae --version
else
    echo "DAE_BINARY_MISSING"
fi
echo

echo "===== Service ====="
if [ -x /etc/init.d/dae ]; then
    /etc/init.d/dae status || true
else
    echo "DAE_INIT_MISSING"
fi

echo
if [ -r /sys/kernel/btf/vmlinux ] && command -v dae >/dev/null 2>&1; then
    echo "RESULT: basic DAE runtime prerequisites are present."
else
    echo "RESULT: prerequisites are incomplete; do not enable transparent proxy yet."
fi
