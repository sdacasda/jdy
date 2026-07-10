# 雅典娜 AX6600（RE-CS-02）DAE 专用云编译工程

这是一个可直接上传到 GitHub 的构建工程，目标是生成：

- 京东云雅典娜 AX6600 / `jdcloud_re-cs-02`
- 高通 IPQ60xx
- DAE 轻量后端
- `luci-app-daede`
- 内核内置 BTF：`/sys/kernel/btf/vmlinux`
- `kmod-sched-bpf`、`kmod-veth`、XDP sockets 与 KPROBES
- 雅典娜点阵屏插件
- NSS 基础驱动
- 默认管理地址：`192.168.50.1`

## 为什么不能继续给你现在的 6.12.94 固件强装

你当前固件已经实际确认：

- `BTF_MISSING`
- 缺少 `kmod-sched-bpf`
- 缺少/不匹配 XDP 相关内核模块
- 第三方 DAE IPK 与当前内核构建不匹配

内核模块和 BTF 必须与固件内核同一次构建。这个工程直接从源码编译内核、模块、DAE 和 LuCI，避免 `--force-depends` 带来的崩溃和断网风险。

## 设计取舍

### 保留

- NSS 驱动、PPPoE、qdisc、bridge/vlan manager
- 雅典娜 LED 点阵屏
- Firewall4 / nftables / TPROXY
- DAE 和 daede LuCI
- eMMC 扩容与基本诊断工具

### 默认不装

- PassWall / PassWall2
- OpenClash
- HomeProxy
- MosDNS / SmartDNS / AdGuard Home
- Docker / Samba
- daed 重型后端

### NSS ECM

`kmod-qca-nss-ecm` 被设置成 `m`：

- 会随固件一起编译成与内核严格匹配的 IPK；
- 默认不装入系统；
- 先保证 DAE 能看到并接管流量；
- 以后确实需要试验 ECM 时，可使用构建产物中的对应 IPK，但启用后必须重新检查分流是否被绕过。

## 使用方法

### 1. 新建 GitHub 仓库

在 GitHub 新建一个空仓库，例如：

`Athena-AX6600-DAE-Builder`

把本压缩包里的所有文件和目录上传到仓库根目录，必须保留：

```text
.github/workflows/build-athena-dae.yml
config/athena-dae.config
scripts/check-build-config.sh
scripts/verify-after-flash.sh
docs/刷机与验收说明.md
```

### 2. 允许 GitHub Actions

进入仓库：

```text
Actions → I understand my workflows, go ahead and enable them
```

### 3. 运行构建

进入：

```text
Actions → Build Athena AX6600 DAE → Run workflow
```

参数：

- `source_ref`：保持 `main`
- `config_only`：第一次可选 `true`，只验证配置；正式编译选 `false`

工作流会在 `make defconfig` 后强制检查：

- 内置 BTF
- XDP sockets
- KPROBES / BPF events
- `kmod-sched-bpf`
- `kmod-veth`
- DAE
- daede 的轻量 dae 后端

任一关键项被源码丢弃，工作流会在编译前停止，不生成一个看起来成功但实际上不能运行 DAE 的固件。

### 4. 下载固件

构建成功后，在本次 Action 页面底部下载：

```text
Athena-AX6600-DAE-<commit>
```

其中会包含：

- `*jdcloud_re-cs-02*sysupgrade.bin`
- `*jdcloud_re-cs-02*factory.bin`（若源码生成）
- `.manifest`
- `sha256sums`
- 最终 `.config`
- 刷机后验证脚本
- 可选的 NSS ECM IPK

## 刷机文件选择

你现在已经是 LibWrt/OpenWrt：

> 使用文件名包含 `jdcloud_re-cs-02` 的 `sysupgrade.bin`。

不要在 LuCI 系统升级页面使用 `factory.bin`。

跨分支刷机建议：

- 不保留配置；
- 先备份 ART、校准分区和现有系统配置；
- 确认有 U-Boot/救砖能力；
- 刷写期间不要断电。

## 首次启动

默认管理地址：

```text
http://192.168.50.1
```

建议先通过 LAN 网线进入后台，再设置 Wi-Fi、WAN 和管理员密码。

## DAE 启动前

不要同时运行其他透明代理：

```sh
/etc/init.d/passwall stop 2>/dev/null
/etc/init.d/passwall disable 2>/dev/null
```

本固件默认不编译 PassWall，但恢复旧配置或后续安装时仍要注意。

先运行构建产物中的检查脚本：

```sh
sh /tmp/verify-after-flash.sh
```

看到：

```text
BTF_OK
RESULT: basic DAE runtime prerequisites are present.
```

再进入：

```text
服务 → daede
```

配置建议：

- 后端：`dae`
- LAN：`br-lan`
- WAN：`auto`
- 首次只导入一个已在手机端验证可用的 VLESS + Reality 节点
- 先使用简单的“中国直连、其他代理”规则跑通，再处理严格 DNS 防泄露

## 重要说明

这是一套构建工程，不是我已经在你的实体雅典娜上刷机验证过的二进制。它通过编译前检查消除了你当前已知的 BTF/kmod 问题，但高通 NSS、无线驱动和上游源码更新仍可能产生新的编译或运行问题。先跑 `config_only=true`，再正式编译，是最稳妥的流程。
