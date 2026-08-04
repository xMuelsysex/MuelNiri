<div align="center">

# MuelNiri

**一键配置 Niri + Noctalia 桌面环境** · One-shot Niri desktop setup for Arch / CachyOS

基于 Noctalia V5 的 Material You 桌面：动态取色、毛玻璃、护眼模式、动态壁纸。

</div>

---

## 特性 / Features

- 🪟 **Niri** 滚动式平铺窗口管理器 + **Noctalia V5** 桌面壳（Quickshell）
- 🎨 **Material You** 动态取色：壁纸换色自动同步到 Kitty / Starship / GTK / Niri
- 🌙 **护眼模式**：一键切换暖色温 + 关闭毛玻璃（`Mod+Shift+N`）
- 🎬 **动态壁纸**：mpvpaper 视频壁纸，自动 Monet 抽帧取色
- ⌨️ 中文友好：Rime 雾凇拼音输入法、中文快捷键提示覆盖层
- 🧰 **Shorin 工具箱**：`pac`/`pacd`/`pacr` 包管理 TUI、`sysup` 更新、`quicksave`/`quickload` 快照、录屏菜单
- 🛡️ 安全部署：安装前自动备份旧配置，可随时回滚

## 快速开始 / Quick Start

刚装好的 Arch / CachyOS 系统（任意终端或 TTY）：

```bash
curl -L https://github.com/xMuelsysex/MuelNiri/raw/main/install.sh | bash
```

脚本会自动：

1. 检测环境（Arch 系、sudo、网络），无 AUR 助手时自动编译安装 `paru`
2. 安装**核心软件包**（官方仓库 + AUR，含 Noctalia 桌面壳与 Shorin 工具箱）
3. **备份**已有配置到 `~/.config-backup-<时间戳>/`，再部署 dotfiles
4. 检测 NVIDIA 显卡并自动启用对应环境变量
5. 弹出**可选软件模块**菜单（默认全选，回车确认，`q` 跳过）

## 安装内容 / What gets installed

### 核心（必装）

| 类别 | 软件包 |
|---|---|
| 窗口/桌面 | `niri`、`quickshell-git`、`noctalia-git`（Noctalia V5 桌面壳）、`mpvpaper-git` |
| 壁纸 | `mpvpaper-git`、`ffmpeg`、`matugen` |
| 终端/Shell | `kitty`、`fish`、`starship`、`fastfetch` |
| 输入法 | `fcitx5`、`fcitx5-rime`（雾凇拼音 `rime-ice-git`）、`fcitx5-mozc`（日文）、`rime-wubi`（五笔） |
| 音频 | `pipewire`、`wireplumber`、`easyeffects` |
| 系统集成 | `xdg-desktop-portal-gnome`、`polkit-gnome`、`dconf`、`ddcutil` |
| 文件管理器 | `nautilus`、`ffmpegthumbnailer`、`file-roller`、`gvfs-smb`、`nautilus-open-any-terminal`、`xdg-terminal-exec` |
| TUI 工具 | `btop`、`gdu`、`yazi`、`bluetui`、`cava`、`lazygit`、`neovim`、`fzf`、`cliphist`、`satty`+`grim`+`slurp`（截图）、`cmatrix`/`lolcat`/`sl` |
| Shorin 工具箱 | `shorin-contrib-git`（pac/pacd/pacr/sysup/快照等 23 个 TUI 工具）、`shorin-screenrec-menu-git`、`niri-sidebar-git` |
| 系统实用工具 | `baobab`、`gparted`、`gnome-font-viewer`、`mission-center`、`lact`、`virt-manager`、`nm-connection-editor`、`gnome-calendar`、`gnome-clocks`、`upscaler`、`flatseal`、`pavucontrol`、`mousepad`、`transmission-gtk`、`localsend`、`flclash` |
| CLI 工具 | `eza`、`fd`、`bat`、`fzf`、`jq`、`inotify-tools` |
| 字体 | `ttf-jetbrains-mono-nerd`、`noto-fonts-cjk`、`adw-gtk3` |

### 可选模块（TUI 菜单自选，默认全选）

| 模块 | 软件包 | 说明 |
|---|---|---|
| 浏览器 | `firefox` + `python-pywalfox`、`google-chrome` | 随壁纸自动换肤 |
| 聊天 | `linuxqq` + `linuxqq-clipsync-git`、`wechat-appimage` | QQ / 微信 |
| 游戏 | `steam` + `mangohud` + `gamescope`、`lutris`、`protonplus`、`lsfg-vk-bin`、`mangojuice` | 游戏平台与生态 |
| AI 工具 | `opencode`、`obsidian-bin`、`codex-app-unofficial` | 终端 AI 助手 / 笔记 / Codex |
| 代理 | `clash-verge-rev-bin` | AUR 预编译 |
| 截图 | `mark-shot` | 截图标注（绑定 `Mod+Shift+S`） |
| 视频 | `mpv`（hwdec 优化）、`obs-studio` | 播放 / 录屏直播 |
| VS Code | `visual-studio-code-bin` | AUR 预编译 |
| 桌面管理 | `pins-git`、`gearlever` | .desktop 固定 / AppImage 管理 |

## 快捷键 / Keybindings

`Mod` = Super/Win 键。完整列表：终端运行 `muelhelp keys`，或按 `Mod+Shift+Slash` 打开覆盖层。

| 按键 | 功能 |
|---|---|
| `Mod+Return` | 打开终端 (Kitty) |
| `Mod+Z` | 程序菜单 (Noctalia) |
| `Mod+E` | 文件管理器 (Thunar/Nautilus) |
| `Mod+Q` / `Alt+F4` | 关闭窗口 / 强制杀死窗口 |
| `Mod+O` / `Mod+G` | 工作区概览 |
| `Mod+Shift+S` / `Print` | 截图 (mark-shot / niri) |
| `Mod+Shift+N` | 护眼模式 |
| `Mod+Alt+L` | 锁屏 |
| `Mod+Alt+W` / `Mod+Y` | 切换壁纸 |
| `Mod+Shift+Y` | 动态视频壁纸 |
| `Mod+H` / `J` / `K` / `L` | 焦点移动 |
| `Mod+Ctrl+H/J/K/L` | 移动窗口 |
| `Mod+Alt+Z` | 侧边栏展开/收起 |
| `Mod+F1` | 开关输入法 (fcitx5) |
| `Mod+F3` | 录屏菜单 |
| `Mod+F5` / `Mod+F8` | 快速存档 / 读档 (btrfs 快照) |
| `Mod+Shift+Slash` | 快捷键教程覆盖层 |

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
- **壁纸**：静态壁纸与 3 张压缩版动态壁纸（720p，各 2MB 左右）已随仓库分发；更多视频壁纸请自行放入 `~/Pictures/Wallpapers/video/`
- **locale**：默认 `zh_CN.UTF-8`，若系统未生成该 locale，请修改 `~/.config/niri/config.kdl` 中的 `LANG`
- **NVIDIA**：脚本检测到 NVIDIA 显卡时自动启用 `GBM_BACKEND=nvidia-drm` 等环境变量
- **显示管理器**：脚本不安装 DM；需要的话 `sudo pacman -S ly && sudo systemctl enable ly`
- **AUR 来源包**：`linuxqq`/`wechat-appimage`/`lsfg-vk-bin` 等部分包在 CachyOS / ArchLinuxCN 仓库中也有，脚本统一走 AUR helper 安装以保证标准 Arch 可用

## 致谢 / Credits

- [Shorin-ArchLinux-Guide](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/tree/main) —— 一键配置脚本的模块化设计参考、键位/工具脚本来源
- [NyxNiri](https://github.com/ech678/NyxNiri) —— 本配置的 Noctalia 集成最初来源

## License

GPLv3，见 [LICENSE](LICENSE)。

配置最初来源于 NyxNiri 项目，配合 Noctalia V5 使用；壁纸版权归原作者所有。
