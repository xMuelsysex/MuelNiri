# Noctalia overview animation patch

This patch adds transient dock visibility IPC commands to Noctalia v5:

- `dock-hide-transient`
- `dock-show-transient`

The commands preserve `[dock].enabled` and reuse the dock's native slide animation. MuelNiri's overview listener uses them so the dock animates with the bar when Niri overview opens and closes.

## Usage in this repository

本仓库已收录本补丁（`noctalia-overview-animation.patch`）。构建后把 patched 二进制放到 `~/.local/share/noctalia-overview-animation/noctalia` 即可——本仓库部署的 `~/.local/bin/noctalia` 入口脚本会自动优先使用补丁版，未构建时自动回退系统版本，无需额外配置。

## Build

Apply `noctalia-overview-animation.patch` to Noctalia commit `10caaf62a9a99a32f84c15682041bbada9e5a9b5` (package `noctalia-git 5.0.0.r4980.g10caaf62a-2`) and build the `noctalia` Meson target.

The patched binary is installed at `~/.local/share/noctalia-overview-animation/noctalia`; `~/.local/bin/noctalia` is the session entry point and precedes `/usr/bin` in `PATH`. The distro binary remains available as the rollback target.
