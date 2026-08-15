<div align="center">

# MuelNiri

**Niri + Noctalia 一键安装器** · One-shot Arch Linux desktop installer

基于 Shorin Arch Setup（AGPL-3.0）魔改：模块化安装流程 + btrfs 快照安全网 + 断点续跑 + Noctalia V5 Material You 桌面。

</div>

---

## 特性 / Features

- 🪟 **Niri** 滚动式平铺窗口管理器 + **Noctalia V5** 桌面壳（Quickshell）
- 🎨 **Material You** 动态取色：壁纸换色自动同步到 Kitty / Starship / GTK / Niri
- 🌙 **护眼模式**：一键切换暖色温 + 关闭毛玻璃（`Mod+Shift+N`）
- 🎬 **动态壁纸**：mpvpaper 视频壁纸，自动 Monet 抽帧取色
- ⌨️ 中文友好：Rime 雾凇拼音输入法、中文快捷键提示覆盖层
- 🧰 **Shorin 工具箱**：`pac`/`pacd`/`pacr` 包管理 TUI、`sysup` 更新、`quicksave`/`quickload` 快照、录屏菜单
- 🛡️ **系统级安全网**：btrfs 快照（`Before MuelNiri Setup`）、断点续跑（.muelniri_install_progress）、应急回滚工具
- 📦 **模块化架构**：fzf 桌面菜单 + 可选模块（IWD WiFi / 双系统 / GPU 驱动 / GRUB 主题 / 常用软件）

## 快速开始 / Quick Start

刚装好的 Arch / CachyOS 系统（任意终端或 TTY）：

```bash
curl -L https://github.com/xMuelsysex/MuelNiri/raw/main/strap.sh | bash
```

安装流程：

1. **引导器**（strap.sh）：环境检测（Linux / x86_64 / 非 Live 环境）→ 下载仓库 → 提权执行
2. **主安装器**（install.sh）：
   - fzf 菜单选择桌面：**MuelNiri Noctalia Niri**（推荐）/ Minimal Niri / 无桌面
   - fzf 多选可选模块（默认全选，Ctrl-X 跳过全部）
   - 镜像优化（reflector，中国时区可跳过）→ keyring 更新 → 全系统更新
   - 必装链：btrfs 快照安全网 → base 配置（multilib/字体/locale/archlinuxcn/AUR 助手）→ 用户账户 → 必备软件 → 桌面快照 → 验证
   - 断点续跑：中断后重跑自动跳过已完成模块（删除 `.muelniri_install_progress` 强制重跑）
3. **完成**：清理中间快照 → 重建 GRUB → 自动重启

## 桌面模块（04k）安装内容

| 类别 | 内容 |
|---|---|
| 窗口/桌面 | `niri`、`quickshell-git`、`noctalia-git`、`mpvpaper-git`、`niri-sidebar-git` |
| 配置部署 | 备份旧配置到 `~/.config-backup-<时间戳>/` → 部署 `dotfiles/` → `__HOME__` 替换 → effects.kdl 软链 → NVIDIA 环境变量自动启用 |
| 壁纸 | 静态壁纸 + 动态视频壁纸（mp4 → `~/Pictures/Wallpapers/video/`） |
| 主题 | `adw-gtk-theme-git`、`matugen`、`pywalfox`、`nwg-look`、`breeze-cursors`、Flatpak 主题覆盖 |
| 输入法 | fcitx5 + Rime 雾凇拼音（`rime-ice-git` + 词汇/翻译增强） |
| 显示管理器 | 自动安装并启用 `ly`（检测到已有 DM 时跳过） |
| 浏览器政策 | Firefox 自动安装 pywalfox + uBlock Origin 扩展 |

完整包清单见 [`pkglist/core.txt`](pkglist/core.txt)（官方）与 [`pkglist/aur.txt`](pkglist/aur.txt)（AUR/CN 源）。

### 可选模块（fzf 多选，默认全选）

| 模块 | 说明 |
|---|---|
| IWD WiFi 后端 | NetworkManager → IWD 切换 |
| Windows 双系统 | 双启动时间修复等 |
| GPU 驱动 | NVIDIA/AMD 驱动自动安装 |
| GRUB 主题 | GRUB 美化 |
| 常用软件 | fzf 多选安装（清单来自 `pkglist/apps/*.txt`） |

## 快捷键 / Keybindings

`Mod` = Super/Win 键。完整列表：终端运行 `muelhelp keys`，或按 `Mod+Shift+Slash` 打开覆盖层。

| 按键 | 功能 |
|---|---|
| `Mod+Return` | 打开终端 (Kitty) |
| `Mod+Z` | 程序菜单 (Noctalia) |
| `Mod+E` | 文件管理器 (Nautilus) |
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

## 回滚 / Rollback

安装器全程有 btrfs 快照保护：

```bash
sudo muelniri-undochange      # 整机回滚到 "Before MuelNiri Setup" 快照
sudo muelniri-de-undochange   # 桌面层回滚到 "Before Desktop Environments" 快照
```

（由 00-btrfs-init 安装到 /usr/local/bin，需要 btrfs + snapper + btrfs-assistant）

## 配置更新 / Updating

重新运行一键脚本即可：拉取最新配置 → 自动快照 + 备份旧配置 → 覆盖部署（断点续跑跳过已完成步骤）。

个人改动请写入以下文件，更新时会被保留：

- `~/.config/niri/__custom__.kdl`
- `~/.config/fish/conf.d/__custom__.fish`

## 虚拟机测试 / Testing in a VM

1. 下载 ISO（Arch 官方或 CachyOS）→ virt-manager 建 VM（内存 4-8G、CPU 4 核、磁盘 40G）
2. archinstall：文件系统 ext4 即可（btrfs 可选，快照功能依赖它）；**必须创建普通用户**
3. 装完重启后：

   ```bash
   curl -L https://github.com/xMuelsysex/MuelNiri/raw/main/strap.sh | bash
   ```

4. 验证：`muelhelp`、`ls ~/.config/niri/config.kdl`、`dbus-run-session -- niri`

> 注意：AUR 包（`noctalia-git`/`quickshell-git` 等）编译较慢，10-30 分钟属正常；安装器结束会自动重启。

## 注意事项 / Notes

- **可选增强（Noctalia overview 动画补丁）**：`patches/noctalia-overview-animation/` 收录了 dock 随 overview 收放的补丁（源码级，需自行编译）；构建后放入 `~/.local/share/noctalia-overview-animation/noctalia` 自动生效，入口脚本会回退到系统版
- **回滚**：`~/.config-backup-<时间戳>/` 中保留安装前的全部配置，确认无误后可删除
- **壁纸**：静态壁纸与 3 张压缩版动态壁纸（720p，各 2MB 左右）已随仓库分发；更多视频壁纸请自行放入 `~/Pictures/Wallpapers/video/`
- **locale**：01a-base 模块自动生成 en_US.UTF-8 + zh_CN.UTF-8；TTY 中文显示需要 CJK 控制台字体
- **NVIDIA**：04k 检测到 NVIDIA 显卡时自动启用 `GBM_BACKEND=nvidia-drm` 等环境变量
- **AUR 来源包**：`linuxqq`/`wechat-appimage`/`flclash` 等部分包在 CachyOS / ArchLinuxCN 仓库中也有，统一走 AUR helper 安装以保证标准 Arch 可用

## 致谢 / Credits

- [Shorin Arch Setup](https://github.com/SHORiN-KiWATA/shorin-arch-setup) —— 本安装器架构基底（AGPL-3.0 魔改）
- [Shorin-ArchLinux-Guide](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/tree/main) —— 键位/工具脚本来源
- [NyxNiri](https://github.com/ech678/NyxNiri) —— dotfiles 的 Noctalia 集成最初来源

## License

AGPL-3.0，见 [LICENSE](LICENSE) 与 [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md)。

配置最初来源于 NyxNiri 项目，配合 Noctalia V5 使用；壁纸版权归原作者所有。
