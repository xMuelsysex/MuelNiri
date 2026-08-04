<div align="center">

# Niri Config

**一键配置 Niri + Noctalia 桌面环境** · One-shot Niri desktop setup for Arch / CachyOS

基于 Noctalia V5 的 Material You 桌面：动态取色、毛玻璃、护眼模式、动态壁纸。

</div>

---

## 特性 / Features

- 🪟 **Niri** 滚动式平铺窗口管理器 + **Noctalia V5** 桌面壳（Quickshell）
- 🎨 **Material You** 动态取色：壁纸换色自动同步到 Kitty / Starship / GTK / Niri
- 🌙 **护眼模式**：一键切换暖色温 + 关闭毛玻璃（`Mod+N`）
- 🎬 **动态壁纸**：mpvpaper 视频壁纸，自动 Monet 抽帧取色
- ⌨️ 中文友好：Rime 雾凇拼音输入法、中文快捷键提示覆盖层
- 🛡️ 安全部署：安装前自动备份旧配置，可随时回滚

## 快速开始 / Quick Start

刚装好的 Arch / CachyOS 系统（任意终端或 TTY）：

```bash
curl -L https://github.com/xMuelsysex/niri_config/raw/main/install.sh | bash
```

脚本会自动：

1. 检测环境（Arch 系、sudo、网络），无 AUR 助手时自动编译安装 `paru`
2. 安装**核心软件包**（官方仓库 + AUR）
3. **备份**已有配置到 `~/.config-backup-<时间戳>/`，再部署 dotfiles
4. 检测 NVIDIA 显卡并自动启用对应环境变量
5. 弹出**可选软件模块**菜单（默认全选，回车确认，`q` 跳过）

## 安装内容 / What gets installed

### 核心（必装）

| 类别 | 软件包 |
|---|---|
| 窗口/桌面 | `niri`、`quickshell-git`、`noctalia-git` |
| 壁纸 | `mpvpaper-git`、`ffmpeg` |
| 终端/Shell | `kitty`、`fish`、`starship`、`fastfetch` |
| 输入法 | `fcitx5`、`fcitx5-rime`（雾凇拼音） |
| 音频 | `pipewire`、`wireplumber`、`easyeffects` |
| 系统集成 | `xdg-desktop-portal-gnome`、`polkit-gnome`、`dconf`、`ddcutil` |
| CLI 工具 | `eza`、`fd`、`bat`、`fzf`、`jq`、`inotify-tools` |
| 字体 | `ttf-jetbrains-mono-nerd`、`noto-fonts-cjk`、`adw-gtk3` |

### 可选模块（TUI 菜单自选）

| 模块 | 软件包 | 说明 |
|---|---|---|
| 浏览器 | `firefox` + `python-pywalfox` | 随壁纸自动换肤 |
| VS Code | `visual-studio-code-bin` | AUR 预编译 |
| 截图 | `mark-shot` | 截图标注（绑定 `Mod+Shift+S`） |
| 音乐 | `lx-music-desktop-bin` | AUR 预编译 |
| 视频 | `mpv` | 附带 `hwdec=auto-safe` 优化 |
| 游戏 | `steam` + `mangohud` + `gamescope` | |
| 监控 | `btop` + `mission-center` + `yazi` + `gdu` | |
| 代理 | `clash-verge-rev-bin` | AUR 预编译 |
| DMS | `dms-shell` + `dms-shell-niri` + `dsearch-bin` | Material 3 桌面壳，与 Noctalia **二选一**（见注意事项） |

## 快捷键 / Keybindings

| 按键 | 功能 |
|---|---|
| `Mod+Return` | 打开终端 (Kitty) |
| `Mod+R` / `Mod+Z` | 应用启动器 |
| `Mod+E` | 文件管理器 (Nautilus) |
| `Mod+Q` | 关闭当前窗口 |
| `Mod+Tab` | 工作区概览 |
| `Mod+Shift+S` / `Print` | 截图 |
| `Mod+N` | 护眼模式 |
| `Mod+Alt+L` | 锁屏 |
| `Mod+Alt+W` / `Mod+Y` | 切换壁纸 |
| `Mod+Shift+Y` | 动态视频壁纸 |
| `Mod+Shift+R` | 重载 Niri 配置 |
| `Mod+Slash` | 快捷键提示覆盖层 |

`Mod` = Super/Win 键。完整列表见 `muelhelp`（终端内运行）。

## 启动 Niri / Starting Niri

- **显示管理器**：登录界面选择 Niri 会话
- **无 DM**：TTY 登录后运行

  ```bash
  dbus-run-session -- niri
  ```

## 配置更新 / Updating

重新运行一键脚本即可：拉取最新 dotfiles → 备份旧配置 → 覆盖部署。

个人改动请写入以下文件，更新时会被保留：

- `~/.config/niri/__custom__.kdl`
- `~/.config/fish/conf.d/__custom__.fish`

## 注意事项 / Notes

- **可选增强（Noctalia overview 动画补丁）**：`patches/noctalia-overview-animation/` 收录了 dock 随 overview 收放的补丁（源码级，需自行编译）；构建后放入 `~/.local/share/noctalia-overview-animation/noctalia` 自动生效，入口脚本会回退到系统版
- **回滚**：`~/.config-backup-<时间戳>/` 中保留安装前的全部配置，确认无误后可删除
- **DMS 与 Noctalia 二选一**：两者都是 Quickshell 桌面壳，同时运行会叠加。选装 DMS 后脚本会自动启用其 spawn；若改用 DMS，请注释 `~/.config/niri/config.kdl` 中的 `"noctalia"` spawn 并重载配置（`Mod+Shift+R`）；若保留 Noctalia，请注释 `"dms"` / `"dsearch"` 两行
- **壁纸**：静态壁纸与 3 张压缩版动态壁纸（720p，各 2MB 左右）已随仓库分发；更多视频壁纸请自行放入 `~/Pictures/Wallpapers/video/`
- **locale**：默认 `zh_CN.UTF-8`，若系统未生成该 locale，请修改 `~/.config/niri/config.kdl` 中的 `LANG`
- **NVIDIA**：脚本检测到 NVIDIA 显卡时自动启用 `GBM_BACKEND=nvidia-drm` 等环境变量
- **显示管理器**：脚本不安装 DM；需要的话 `sudo pacman -S ly && sudo systemctl enable ly`

## License

GPLv3，见 [LICENSE](LICENSE)。

配置最初来源于 MuelNiri 项目（原 NyxNiri），配合 Noctalia V5 使用；壁纸版权归原作者所有。
