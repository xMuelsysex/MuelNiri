#!/usr/bin/env bash
# ==============================================================================
# Niri Config — 一键配置 Niri 桌面环境 (Arch / CachyOS)
#
# 用法:
#   curl -L https://github.com/ech678/niri_config/raw/main/install.sh | bash
#   或克隆仓库后: ./install.sh
#
# 流程: 环境检测 → 安装核心包 → 备份并部署配置 → 可选软件菜单 → 完成提示
# ==============================================================================

set -euo pipefail

# 发布前请把 REPO_URL 换成实际仓库地址
REPO_URL="${REPO_URL:-https://github.com/xMuelsysex/niri_config.git}"
REPO_BRANCH="main"

# ---------- 颜色 ----------
C_RESET=$'\e[0m'
C_BOLD=$'\e[1m'
C_GREEN=$'\e[32m'
C_YELLOW=$'\e[33m'
C_RED=$'\e[31m'
C_CYAN=$'\e[36m'

info()  { echo -e "${C_CYAN}[*]${C_RESET} $*"; }
ok()    { echo -e "${C_GREEN}[+]${C_RESET} $*"; }
warn()  { echo -e "${C_YELLOW}[!]${C_RESET} $*"; }
die()   { echo -e "${C_RED}[-]${C_RESET} $*" >&2; exit 1; }

# ---------- 临时清理 ----------
declare -a CLEANUP_PATHS=()
cleanup() {
    local p
    for p in "${CLEANUP_PATHS[@]:-}"; do
        [ -n "$p" ] && rm -rf "$p"
    done
}
trap cleanup EXIT INT TERM

# ---------- 0. 环境检测 ----------
require_user() {
    [ "$(id -u)" -eq 0 ] && die "请勿以 root 运行本脚本，请用普通用户执行（需要 sudo 权限）。"
    command -v sudo >/dev/null 2>&1 || die "未找到 sudo，请先安装 sudo 并配置当前用户。"
    sudo -v || die "sudo 认证失败。"
}

detect_distro() {
    local id=""
    [ -f /etc/os-release ] && id="$(. /etc/os-release; echo "$ID")"
    case "$id" in
        arch|cachyos) : ;;
        *) warn "当前发行版 ($id) 非 Arch/CachyOS，脚本可能无法正常工作，继续运行？(y/N)"
           read -r ans < /dev/tty
           [[ "$ans" =~ ^[Yy]$ ]] || exit 0 ;;
    esac
}

# ---------- 1. 定位仓库源 ----------
locate_source() {
    # 仓库内运行（本地模式）：当前目录包含 dotfiles/ 与 pkglist/
    if [ -f "./dotfiles/.config/niri/config.kdl" ] && [ -f "./pkglist/core.txt" ]; then
        SOURCE_DIR="$(pwd)"
        RUN_MODE="local"
        info "本地模式：使用当前目录 ($SOURCE_DIR)"
        return
    fi

    # 管道模式（curl | bash）：克隆仓库到缓存目录
    RUN_MODE="remote"
    SOURCE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/niri-config"
    info "远程模式：克隆仓库到 $SOURCE_DIR"
    if [ -d "$SOURCE_DIR/.git" ]; then
        git -C "$SOURCE_DIR" fetch --depth 1 origin "$REPO_BRANCH" >/dev/null 2>&1 \
            && git -C "$SOURCE_DIR" reset --hard "origin/$REPO_BRANCH" >/dev/null 2>&1 \
            || warn "更新缓存仓库失败，使用已有副本。"
    else
        git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$SOURCE_DIR"
    fi
}

# ---------- 2. 包管理器 ----------
detect_aur_helper() {
    if command -v paru >/dev/null 2>&1; then
        AUR_HELPER="paru"
    elif command -v yay >/dev/null 2>&1; then
        AUR_HELPER="yay"
    else
        AUR_HELPER=""
    fi
}

install_paru() {
    info "未检测到 AUR 助手，正在自动编译安装 paru ..."
    local build_dir
    build_dir="$(mktemp -d)"
    CLEANUP_PATHS+=("$build_dir")
    sudo pacman -S --needed --noconfirm base-devel git >/dev/null
    git clone --depth 1 https://aur.archlinux.org/paru.git "$build_dir/paru"
    ( cd "$build_dir/paru" && makepkg -si --noconfirm )
    AUR_HELPER="paru"
}

install_core() {
    info "安装核心软件包（官方仓库）..."
    sudo pacman -S --needed --noconfirm $(cat "$SOURCE_DIR/pkglist/core.txt")

    detect_aur_helper
    if [ -z "$AUR_HELPER" ]; then
        install_paru
    fi
    ok "AUR 助手: $AUR_HELPER"

    info "安装核心软件包（AUR）..."
    "$AUR_HELPER" -S --needed --noconfirm $(cat "$SOURCE_DIR/pkglist/aur.txt")
}

# ---------- 3. 部署配置 ----------
DEPLOY_TARGETS=(
    ".config/niri"
    ".config/noctalia"
    ".config/kitty"
    ".config/fish"
    ".config/fastfetch"
    ".config/fcitx5"
    ".config/starship.toml"
    ".local/share/fcitx5/rime"
)

backup_existing() {
    local ts target parent
    ts="$(date +%Y%m%d-%H%M%S)"
    BACKUP_DIR="$HOME/.config-backup-$ts"
    mkdir -p "$BACKUP_DIR"
    for target in "${DEPLOY_TARGETS[@]}"; do
        if [ -e "$HOME/$target" ]; then
            parent="$(dirname "$target")"
            mkdir -p "$BACKUP_DIR/$parent"
            mv "$HOME/$target" "$BACKUP_DIR/$target"
            warn "已备份原有 $target → $BACKUP_DIR/$target"
        fi
    done
}

deploy_dotfiles() {
    info "备份已有配置..."
    backup_existing

    info "部署配置文件..."
    cp -a "$SOURCE_DIR/dotfiles/." "$HOME/"

    # 占位符替换（noctalia 壁纸/脚本路径）
    sed -i "s|__HOME__|$HOME|g" "$HOME/.config/noctalia/config.toml"

    # effects.kdl 符号链接（护眼模式切换用）
    if [ ! -L "$HOME/.config/niri/effects.kdl" ]; then
        ln -sfn effects_normal.kdl "$HOME/.config/niri/effects.kdl"
    fi

    # 壁纸（不覆盖用户已有的同名文件，排除 video 子目录）
    if [ -d "$SOURCE_DIR/Wallpapers" ]; then
        mkdir -p "$HOME/Pictures/Wallpapers"
        find "$SOURCE_DIR/Wallpapers" -maxdepth 1 -type f -exec cp -n {} "$HOME/Pictures/Wallpapers/" \; 2>/dev/null || true
        ok "壁纸已复制到 ~/Pictures/Wallpapers"
    fi

    # 视频壁纸（mpvpaper 动态壁纸）
    if [ -d "$SOURCE_DIR/Wallpapers/video" ] && [ -n "$(ls -A "$SOURCE_DIR/Wallpapers/video" 2>/dev/null)" ]; then
        mkdir -p "$HOME/Pictures/Wallpapers/video"
        cp -n "$SOURCE_DIR/Wallpapers/video/"* "$HOME/Pictures/Wallpapers/video/" 2>/dev/null || true
        ok "动态壁纸已复制到 ~/Pictures/Wallpapers/video"
    fi

    # NVIDIA 显卡：启用 config.kdl 中的 NVIDIA 环境变量
    if lspci -k 2>/dev/null | grep -qi 'VGA.*NVIDIA\|3D.*NVIDIA'; then
        info "检测到 NVIDIA 显卡，启用相关环境变量..."
        sed -i \
            -e 's|^    // GBM_BACKEND|    GBM_BACKEND|' \
            -e 's|^    // __GLX_VENDOR_LIBRARY_NAME|    __GLX_VENDOR_LIBRARY_NAME|' \
            -e 's|^    // LIBVA_DRIVER_NAME|    LIBVA_DRIVER_NAME|' \
            "$HOME/.config/niri/config.kdl"
    fi

    # 安装 fish 插件（fisher，失败不影响主流程）
    if command -v fish >/dev/null 2>&1 && [ -f "$HOME/.config/fish/fish_plugins" ]; then
        fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; and fisher update' >/dev/null 2>&1 \
            && ok "fish 插件已安装 (fisher)" \
            || warn "fish 插件安装失败，可稍后手动运行 fisher update"
    fi

    # mpv 可选配置（若安装了 mpv 且无现有配置）
    if [ -f "$SOURCE_DIR/dotfiles/.config/mpv/config" ] && [ ! -f "$HOME/.config/mpv/config" ]; then
        mkdir -p "$HOME/.config/mpv"
        cp "$SOURCE_DIR/dotfiles/.config/mpv/config" "$HOME/.config/mpv/config"
    fi
}

# ---------- 4. 可选软件菜单 ----------
load_app_modules() {
    APP_MODULES=()
    local f desc
    for f in "$SOURCE_DIR"/pkglist/apps/*.txt; do
        [ -f "$f" ] || continue
        desc="$(grep -m1 '^#' "$f" | sed 's/^# //')"
        APP_MODULES+=("$(basename "$f" .txt)|$desc|$f")
    done
}

# DMS 桌面壳：部署配置并启用 niri 侧 spawn（DMS 与 Noctalia 二选一）
deploy_dms() {
    info "部署 DMS 配置..."
    local t
    for t in ".config/DankMaterialShell" ".config/danksearch"; do
        if [ -e "$HOME/$t" ]; then
            mkdir -p "$BACKUP_DIR/$(dirname "$t")"
            mv "$HOME/$t" "$BACKUP_DIR/$t"
            warn "已备份原有 $t → $BACKUP_DIR/$t"
        fi
    done
    mkdir -p "$HOME/.config/DankMaterialShell" "$HOME/.config/danksearch" "$HOME/.local/bin"
    cp -a "$SOURCE_DIR/dotfiles-extra/dms/.config/DankMaterialShell/." "$HOME/.config/DankMaterialShell/"
    cp -a "$SOURCE_DIR/dotfiles-extra/dms/.config/danksearch/." "$HOME/.config/danksearch/"
    cp -n "$SOURCE_DIR/dotfiles-extra/dms/.local/bin/random-anime-wallpaper-dms" "$HOME/.local/bin/" 2>/dev/null || true

    sed -i "s|__HOME__|$HOME|g" "$HOME/.config/danksearch/config.toml"

    # 启用 niri 配置中的 DMS spawn（此前被注释的 Noctalia 迁移残留）
    sed -i 's|^// spawn-at-startup "dms" "run"|spawn-at-startup "dms" "run"|' "$HOME/.config/niri/config.kdl"
    sed -i 's|^// spawn-at-startup "dsearch" "serve"|spawn-at-startup "dsearch" "serve"|' "$HOME/.config/niri/config.kdl"

    warn "DMS 与 Noctalia 是两套桌面壳，建议二选一："
    warn "  保留 Noctalia：注释掉 config.kdl 中 'spawn-at-startup \"dms\"' 与 '\"dsearch\"' 两行"
    warn "  改用 DMS：注释掉 config.kdl 中 '\"noctalia\"' spawn，并重载配置 (Mod+Shift+R)"
    warn "  DMS 随机壁纸命令: random-anime-wallpaper-dms"
}

# 模块安装后的额外部署钩子
module_post_deploy() {
    case "$1" in
        dms) deploy_dms ;;
    esac
}

app_menu() {
    load_app_modules
    [ "${#APP_MODULES[@]}" -eq 0 ] && return

    local -a sel=()
    local i m name

    echo
    info "可选软件模块（默认全部安装）"
    echo "  输入模块编号切换选中/取消，回车确认，q 跳过"
    echo "  ${C_BOLD}------------------------------------------${C_RESET}"

    # 默认全选
    for ((i=0; i<${#APP_MODULES[@]}; i++)); do
        sel[$i]=1
    done

    while true; do
        echo
        for ((i=0; i<${#APP_MODULES[@]}; i++)); do
            m="${APP_MODULES[$i]}"
            name="${m%%|*}"
            desc="${m#*|}"
            desc="${desc%%|*}"
            if [ "${sel[$i]}" -eq 1 ]; then
                printf "  ${C_GREEN}[x]${C_RESET} %2d) %-12s %s\n" "$((i+1))" "$name" "$desc"
            else
                printf "  [ ] %2d) %-12s %s\n" "$((i+1))" "$name" "$desc"
            fi
        done
        printf "  ${C_BOLD}------------------------------------------${C_RESET}\n"
        read -rp "  选择 (回车继续 / q 跳过): " choice < /dev/tty

        [ -z "$choice" ] && break
        [[ "$choice" =~ ^[Qq]$ ]] && { for ((i=0; i<${#APP_MODULES[@]}; i++)); do sel[$i]=0; done; break; }

        for num in $choice; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#APP_MODULES[@]}" ]; then
                sel[$((num-1))]=$(( 1 - sel[$((num-1))] ))
            fi
        done
    done

    # 安装所选模块
    for ((i=0; i<${#APP_MODULES[@]}; i++)); do
        [ "${sel[$i]}" -eq 1 ] || continue
        m="${APP_MODULES[$i]}"
        name="${m%%|*}"
        file="${m##*|}"
        info "安装模块: $name"
        while IFS= read -r line; do
            case "$line" in
                repo:*) sudo pacman -S --needed --noconfirm ${line#repo:} ;;
                aur:*)  "$AUR_HELPER" -S --needed --noconfirm ${line#aur:} ;;
            esac
        done < <(grep -vE '^\s*#|^\s*$' "$file")
        module_post_deploy "$name"
    done
}

# ---------- 5. 完成提示 ----------
print_tutorial() {
    cat << EOF

${C_BOLD}${C_GREEN}============================================${C_RESET}
${C_BOLD}  安装完成！Niri 桌面环境已配置就绪${C_RESET}
${C_BOLD}${C_GREEN}============================================${C_RESET}

${C_BOLD}启动 Niri：${C_RESET}
  1. 显示管理器：在登录界面选择 Niri 会话（需先安装 ly/sddm 等）
  2. 无显示管理器：在 TTY 登录后运行
       dbus-run-session -- niri
     （或在 ~/.bashrc 中加入 exec 实现自动登录）

${C_BOLD}核心快捷键（Mod = Super/Win 键）：${C_RESET}
  Mod+Return        打开终端 (Kitty)
  Mod+R / Mod+Z     应用启动器 (Noctalia)
  Mod+E             文件管理器 (Nautilus)
  Mod+Q             关闭当前窗口
  Mod+Tab           工作区概览
  Mod+Shift+S       截图
  Mod+N             护眼模式 (暖色温)
  Mod+Alt+L         锁屏
  Mod+Shift+R       重载 Niri 配置
  Mod+Slash         快捷键提示覆盖层

${C_BOLD}常用命令：${C_RESET}
  nyxhelp           终端与桌面速查手册
  niri msg action screenshot  手动截图

${C_BOLD}壁纸：${C_RESET}
  Mod+Alt+W / Mod+Y 切换壁纸（静态，自动 Monet 取色）
  Mod+Shift+Y       动态视频壁纸（mp4 放入 ~/Pictures/Wallpapers/video/）

${C_BOLD}可选增强：${C_RESET}
  Noctalia overview 动画补丁（dock 随 overview 收起/展开）见
  patches/noctalia-overview-animation/README.md，构建后自动生效。

${C_BOLD}输入法：${C_RESET}
  fcitx5 已配置 Rime（雾凇拼音）。首次使用请打开"输入法配置"添加。

${C_BOLD}配置更新：${C_RESET}
  重新运行本脚本即可拉取最新配置并覆盖部署（自动备份旧配置）。
  备份位于 ~/.config-backup-<时间戳>/，确认无误后可删除。

${C_BOLD}自定义：${C_RESET}
  个人改动请写入 ~/.config/niri/__custom__.kdl 与
  ~/.config/fish/conf.d/__custom__.fish（更新时保留）。

祝使用愉快！有问题欢迎到项目仓库反馈。
EOF
}

# ---------- main ----------
main() {
    echo
    echo -e "${C_BOLD}${C_CYAN}  Niri Config — 一键配置 Niri 桌面环境${C_RESET}"
    echo

    require_user
    detect_distro
    locate_source

    command -v git >/dev/null 2>&1 || die "未找到 git，请先安装: sudo pacman -S git"
    command -v lspci >/dev/null 2>&1 || warn "未找到 lspci（pciutils），跳过 NVIDIA 检测。"

    install_core
    deploy_dotfiles
    app_menu
    print_tutorial
}

main "$@"
