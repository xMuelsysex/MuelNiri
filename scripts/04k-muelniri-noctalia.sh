#!/usr/bin/env bash

# ==============================================================================
# 04k-muelniri-noctalia.sh - MuelNiri Noctalia Niri Desktop Module
# 基于 Shorin Arch Setup 04k 模块（AGPL-3.0）魔改
# 流程：备份配置 → 核心包（pkglist） → 部署 dotfiles → 壁纸 → 终端/输入法
#       → Nautilus → Flatpak 主题 → Firefox 政策 → ly 显示管理器
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

if [[ -f "$SCRIPT_DIR/00-utils.sh" ]]; then
    source "$SCRIPT_DIR/00-utils.sh"
else
    echo "Error: 00-utils.sh not found in $SCRIPT_DIR."
    exit 1
fi

check_root
VERIFY_LIST="/tmp/muelniri_install_verify.list"
rm -f "$VERIFY_LIST" # 确保每次运行生成全新的订单

# --- Identify User & DM Check ---
log "Identifying target user..."
detect_target_user

if [[ -z "$TARGET_USER" || ! -d "$HOME_DIR" ]]; then
    error "Target user invalid or home directory does not exist."
    exit 1
fi

info_kv "Target User" "$TARGET_USER"

check_dm_conflict

# --- Temporary Sudo Privileges ---
log "Granting temporary sudo privileges..."
SUDO_TEMP_FILE="/etc/sudoers.d/99_muelniri_installer_temp"
echo "$TARGET_USER ALL=(ALL) NOPASSWD: ALL" > "$SUDO_TEMP_FILE"
chmod 440 "$SUDO_TEMP_FILE"

cleanup_sudo() {
    if [[ -f "$SUDO_TEMP_FILE" ]]; then
        rm -f "$SUDO_TEMP_FILE"
        log "Security: Temporary sudo privileges revoked."
    fi
}
trap cleanup_sudo EXIT INT TERM

# --- 0. Backup Existing Configs ---
section "MuelNiri Noctalia" "Backup Existing Configurations"

DEPLOY_TARGETS=(
    ".config/niri"
    ".config/noctalia"
    ".config/kitty"
    ".config/fish"
    ".config/fastfetch"
    ".config/fcitx5"
    ".config/zed"
    ".config/starship.toml"
    ".local/bin/noctalia"
    ".local/share/fcitx5/rime"
)

BACKUP_DIR="$HOME_DIR/.config-backup-$(date +%Y%m%d-%H%M%S)"
as_user mkdir -p "$BACKUP_DIR"
for target in "${DEPLOY_TARGETS[@]}"; do
    if [ -e "$HOME_DIR/$target" ]; then
        parent="$(dirname "$target")"
        as_user mkdir -p "$BACKUP_DIR/$parent"
        as_user mv "$HOME_DIR/$target" "$BACKUP_DIR/$target"
        warn "已备份原有 $target → ~/$(basename "$BACKUP_DIR")/$target"
    fi
done
success "备份完成：~/$(basename "$BACKUP_DIR")/"

# --- 1. Core Packages (pkglist 为唯一事实来源) ---
section "MuelNiri Noctalia" "Core Packages (Official Repo)"

mapfile -t CORE_PKGS < <(grep -vE '^\s*#|^\s*$' "$PARENT_DIR/pkglist/core.txt")
echo "${CORE_PKGS[*]}" >> "$VERIFY_LIST"
if ! exe pacman -S --needed --noconfirm "${CORE_PKGS[@]}"; then
    error "pacman 安装失败：若提示 target not found 请先 sudo pacman -Syy 同步索引；若提示 unresolvable package conflicts 请检查是否有包与已装 AUR 版冲突。"
    exit 1
fi
success "Official repo packages installed."

section "MuelNiri Noctalia" "Core Packages (AUR)"

mapfile -t AUR_PKGS < <(grep -vE '^\s*#|^\s*$' "$PARENT_DIR/pkglist/aur.txt")
echo "${AUR_PKGS[*]}" >> "$VERIFY_LIST"

AUR_HELPER=""
command -v paru >/dev/null 2>&1 && AUR_HELPER="paru"
command -v yay  >/dev/null 2>&1 && AUR_HELPER="${AUR_HELPER:-yay}"
if [ -z "$AUR_HELPER" ]; then
    log "未检测到 AUR 助手，安装 paru..."
    exe pacman -S --noconfirm --needed base-devel paru
    AUR_HELPER="paru"
fi
info_kv "AUR Helper" "$AUR_HELPER"
exe as_user "$AUR_HELPER" -S --needed --noconfirm "${AUR_PKGS[@]}"
success "AUR packages installed."

# --- 2. Deploy Dotfiles ---
section "MuelNiri Noctalia" "Deploy Dotfiles"

DOTFILES_SRC="$PARENT_DIR/dotfiles"
chown -R "$TARGET_USER:" "$DOTFILES_SRC" 2>/dev/null || true
force_copy "$DOTFILES_SRC/." "$HOME_DIR"

# __HOME__ 占位符替换（noctalia 壁纸/脚本路径）
if [ -f "$HOME_DIR/.config/noctalia/config.toml" ]; then
    as_user sed -i "s|__HOME__|$HOME_DIR|g" "$HOME_DIR/.config/noctalia/config.toml"
    success "noctalia config.toml 占位符已替换"
fi

# effects.kdl 符号链接（护眼模式切换用）
if [ ! -L "$HOME_DIR/.config/niri/effects.kdl" ] && [ -f "$HOME_DIR/.config/niri/effects_normal.kdl" ]; then
    as_user ln -sfn effects_normal.kdl "$HOME_DIR/.config/niri/effects.kdl"
    success "effects.kdl 符号链接已创建"
fi

# NVIDIA 显卡：启用 config.kdl 中的 NVIDIA 环境变量
if lspci -k 2>/dev/null | grep -qi 'VGA.*NVIDIA\|3D.*NVIDIA'; then
    log "检测到 NVIDIA 显卡，启用相关环境变量..."
    as_user sed -i \
        -e 's|^    // GBM_BACKEND|    GBM_BACKEND|' \
        -e 's|^    // __GLX_VENDOR_LIBRARY_NAME|    __GLX_VENDOR_LIBRARY_NAME|' \
        -e 's|^    // LIBVA_DRIVER_NAME|    LIBVA_DRIVER_NAME|' \
        "$HOME_DIR/.config/niri/config.kdl" 2>/dev/null || true
fi

# --- 3. Wallpapers ---
section "MuelNiri Noctalia" "Wallpapers"

WALLPAPER_SRC="$PARENT_DIR/Wallpapers"
if [ -d "$WALLPAPER_SRC" ]; then
    as_user mkdir -p "$HOME_DIR/Pictures/Wallpapers"
    find "$WALLPAPER_SRC" -maxdepth 1 -type f -exec as_user cp -n {} "$HOME_DIR/Pictures/Wallpapers/" \; 2>/dev/null || true
    if [ -d "$WALLPAPER_SRC/video" ] && [ -n "$(ls -A "$WALLPAPER_SRC/video" 2>/dev/null)" ]; then
        as_user mkdir -p "$HOME_DIR/Pictures/Wallpapers/video"
        as_user cp -n "$WALLPAPER_SRC/video/"* "$HOME_DIR/Pictures/Wallpapers/video/" 2>/dev/null || true
        success "动态壁纸已复制到 ~/Pictures/Wallpapers/video"
    fi
    success "壁纸已复制到 ~/Pictures/Wallpapers"
fi

# --- 4. Fish / Terminal / Templates ---
section "MuelNiri Noctalia" "Fish & Terminal Setup"

# fish 插件（fisher，失败不影响主流程）
if command -v fish >/dev/null 2>&1 && [ -f "$HOME_DIR/.config/fish/fish_plugins" ]; then
    as_user fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; and fisher update' >/dev/null 2>&1 \
        && success "fish 插件已安装 (fisher)" \
        || warn "fish 插件安装失败，可稍后手动运行 fisher update"
fi

# mpv 可选配置（若安装了 mpv 且无现有配置）
if [ -f "$DOTFILES_SRC/.config/mpv/config" ] && [ ! -f "$HOME_DIR/.config/mpv/config" ]; then
    as_user mkdir -p "$HOME_DIR/.config/mpv"
    as_user cp "$DOTFILES_SRC/.config/mpv/config" "$HOME_DIR/.config/mpv/config"
fi

# 模板文件
as_user mkdir -p "$HOME_DIR/Templates"
[ -f "$HOME_DIR/Templates/new.sh" ] || as_user bash -c "printf '#!/usr/bin/env bash\n' > '$HOME_DIR/Templates/new.sh'"
as_user touch "$HOME_DIR/Templates/new"

# 默认终端
if [ ! -f "$HOME_DIR/.config/xdg-terminals.list" ] || ! grep -q kitty "$HOME_DIR/.config/xdg-terminals.list" 2>/dev/null; then
    as_user mkdir -p "$HOME_DIR/.config"
    as_user bash -c "printf 'kitty.desktop\n' >> '$HOME_DIR/.config/xdg-terminals.list'"
fi
if command -v gsettings >/dev/null 2>&1; then
    as_user dbus-run-session gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal kitty 2>/dev/null || true
fi

# --- 5. File Manager ---
section "MuelNiri Noctalia" "File Manager"

configure_nautilus_user
run_hide_desktop_file

# --- 6. Shorin Ecosystem (容错) ---
section "MuelNiri Noctalia" "Shorin Tools"

if command -v shorin >/dev/null 2>&1; then
    as_user shorin link || warn "shorin link 失败"
fi
if command -v miyu >/dev/null 2>&1; then
    as_user miyu fish-init || warn "miyu fish-init 失败"
fi

# --- 7. Flatpak & Theme Integration ---
section "MuelNiri Noctalia" "Flatpak & Theme Integration"

if command -v flatpak >/dev/null 2>&1; then
    log "Configuring Flatpak overrides and themes..."
    as_user flatpak override --user --filesystem=xdg-data/themes
    as_user flatpak override --user --filesystem="$HOME_DIR/.themes"
    as_user flatpak override --user --filesystem=xdg-config/gtk-4.0
    as_user flatpak override --user --filesystem=xdg-config/gtk-3.0
    as_user flatpak override --user --env=GTK_THEME=adw-gtk3-dark
    as_user flatpak override --user --filesystem=xdg-config/fontconfig
    as_user ln -sf /usr/share/themes "$HOME_DIR/.local/share/themes" 2>/dev/null || true
    success "Flatpak theme overrides applied."
fi

# --- 8. Firefox Extensions Policy ---
section "MuelNiri Noctalia" "Firefox Extensions Policy"

POL_DIR="/etc/firefox/policies"
mkdir -p "$POL_DIR"
cat << 'EOF' > "$POL_DIR/policies.json"
{
  "policies": {
    "Extensions": {
      "Install": [
        "https://addons.mozilla.org/firefox/downloads/latest/pywalfox/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
      ]
    }
  }
}
EOF
chmod 755 "$POL_DIR"
chmod 644 "$POL_DIR/policies.json"
success "Firefox 扩展政策已写入（pywalfox + uBlock Origin）"

# --- 9. Tutorial & Verification ---
section "MuelNiri Noctalia" "Tutorial & Blackbox Check"

if [ -f "$PARENT_DIR/resources/必看-MuelNiri-Noctalia-Niri使用方法.txt" ]; then
    force_copy "$PARENT_DIR/resources/必看-MuelNiri-Noctalia-Niri使用方法.txt" "$HOME_DIR"
fi

for c in noctalia quickshell; do
    command -v "$c" >/dev/null 2>&1 || warn "未找到 $c 命令——Noctalia 可能安装失败，请检查 AUR 构建日志"
done

# --- 10. Display Manager & Auto-Login ---
section "MuelNiri Noctalia" "Display Manager"

# 清理遗留 TTY autologin 配置
rm -f /etc/systemd/system/getty@tty1.service.d/autologin.conf 2>/dev/null

if [ "$SKIP_DM" = true ]; then
    log "Display Manager setup skipped (Conflict found or user opted out)."
    warn "You will need to start your session manually from the TTY."
else
    setup_ly
fi

log "Module 04k completed."
