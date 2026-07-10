# 雅典娜 AX6600 DAED 自愈云编译版

本版本只要求 `.github/workflows/build-athena-daed.yml` 存在即可运行。

- 如果仓库中存在 `config/athena-daed.config`，优先使用你的自定义配置。
- 如果该文件缺失，工作流自动生成安全默认配置。
- 配置检查已内嵌，不依赖脚本执行权限。
- 即使前置步骤失败，也会生成 BUILD_INFO 和诊断产物，不再出现空 artifact 连锁报错。

## 更新参数

- `source_ref=main`：使用最新雅典娜固件源码。
- `daede_ref=main`：使用最新 openwrt-daede 打包版本。
- 需要回退时，把 `daede_ref` 改成某个发布标签或提交，例如 `v2026.07.09`。
- 第一次勾选 `config_only`；通过后取消勾选正式编译。

## 更新原则

- 只更新 DAED/面板：优先在 LuCI「服务 → daede → 更新」中操作。
- 更新内核、NSS、BTF 或底层固件：重新运行本工作流并刷新的 sysupgrade。
- 不要用 `opkg upgrade` 批量升级所有内核模块。
