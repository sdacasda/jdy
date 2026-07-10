#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:-.config}"

required=(
  "CONFIG_TARGET_qualcommax_ipq60xx_DEVICE_jdcloud_re-cs-02=y"
  "CONFIG_KERNEL_DEBUG_INFO=y"
  "CONFIG_KERNEL_DEBUG_INFO_BTF=y"
  "CONFIG_KERNEL_XDP_SOCKETS=y"
  "CONFIG_KERNEL_KPROBES=y"
  "CONFIG_KERNEL_KPROBE_EVENTS=y"
  "CONFIG_KERNEL_BPF_EVENTS=y"
  "CONFIG_PACKAGE_kmod-sched-bpf=y"
  "CONFIG_PACKAGE_kmod-veth=y"
  "CONFIG_PACKAGE_dae=y"
  "CONFIG_DAE_USE_KERNEL_BTF=y"
  "CONFIG_PACKAGE_luci-app-daede=y"
  "CONFIG_PACKAGE_luci-app-daede_dae=y"
)

failed=0
for item in "${required[@]}"; do
  if ! grep -qxF "$item" "$CONFIG_FILE"; then
    echo "[ERROR] Missing after make defconfig: $item"
    failed=1
  fi
done

for forbidden in \
  "CONFIG_PACKAGE_luci-app-passwall=y" \
  "CONFIG_PACKAGE_luci-app-passwall2=y" \
  "CONFIG_PACKAGE_luci-app-openclash=y" \
  "CONFIG_PACKAGE_daed=y"; do
  if grep -qxF "$forbidden" "$CONFIG_FILE"; then
    echo "[ERROR] Conflicting/unwanted selection: $forbidden"
    failed=1
  fi
done

if [[ "$failed" -ne 0 ]]; then
  echo
  echo "Configuration validation failed. Stop before compiling an unusable firmware."
  exit 1
fi

echo "[OK] DAE, integrated BTF, XDP sockets and required kmods are selected."
