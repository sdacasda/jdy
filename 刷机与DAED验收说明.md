# 刷机与更新说明

当前已经是 OpenWrt/LibWrt 时，只使用文件名包含 `jdcloud_re-cs-02` 的 `sysupgrade.bin`。

首次刷入本专版建议不保留旧配置。刷机后先运行构建产物中的 `verify-after-flash.sh`，确认 BTF 和 DAED 均存在。

DAED 配置升级前应从 Dashboard 导出一份，并在 LuCI 系统备份中保存配置。不要同时启用 PassWall、OpenClash、HomeProxy 和 DAED。
