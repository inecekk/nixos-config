#!/usr/bin/env bash
set -euo pipefail

# ============================================
# NixOS Flake 终极个性化安装脚本
# 仓库: https://github.com/inecekk/nixos-config
# 仅在 NixOS Live USB 环境中以 root 运行
# ============================================

REPO_URL="https://github.com/inecekk/nixos-config.git"
HOSTNAME="nixos"
TMP_CONFIG=""
DEFAULT_USER="lk"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

cleanup() { [[ -n "$TMP_CONFIG" && -d "$TMP_CONFIG" ]] && rm -rf "$TMP_CONFIG"; }
trap cleanup EXIT

[[ $EUID -eq 0 ]] || err "请以 root 身份运行此脚本 (sudo $0)"

# ============================================
# 主菜单
# ============================================
echo -e "${CYAN}"
echo "  ╔═══════════════════════════════════════╗"
echo "  ║  NixOS Flake Ultimate Installer       ║"
echo "  ║  Niri + Waybar + Home Manager         ║"
echo "  ╚═══════════════════════════════════════╝"
echo -e "${NC}"
echo "  1) 默认配置安装 (用户: $DEFAULT_USER, 原始 UUID)"
echo "  2) 完全自定义安装 (用户/UUID/软件包)"
echo "  3) 仅克隆仓库到 /etc/nixos (不安装系统)"
echo "  0) 退出"
echo ""
read -rp "请选择 [0-3]: " CHOICE

case "$CHOICE" in
        1|2) INSTALL_MODE="$CHOICE" ;;
        3)
        TMP_CONFIG=$(mktemp -d)
        git clone "$REPO_URL" "$TMP_CONFIG"
        mkdir -p /etc/nixos && cp -a "$TMP_CONFIG"/. /etc/nixos/
        chown -R 1000:100 /etc/nixos
        ok "仓库已克隆到 /etc/nixos"; exit 0 ;;
        0) info "已退出"; exit 0 ;;
        *) err "无效选择" ;;
esac

TARGET_USER="$DEFAULT_USER"
EXTRA_PKGS=()

# ============================================
# [选项2] 自定义用户名
# ============================================
if [[ "$INSTALL_MODE" == "2" ]]; then
        read -rp "请输入新用户名 (回车使用默认 $DEFAULT_USER): " INPUT_USER
        TARGET_USER="${INPUT_USER:-$DEFAULT_USER}"
        if ! [[ "$TARGET_USER" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        err "用户名 '$TARGET_USER' 不合法 (仅允许小写字母、数字、下划线、连字符)"
        fi
        info "目标用户名: $TARGET_USER"

        # ============================================
        # [选项2] 自定义额外软件包
        # ============================================
        echo ""
        info "输入需要额外安装的软件包名 (nixpkgs 属性名)"
        info "多个软件用空格分隔，留空跳过"
        info "示例: htop neovim tmux ripgrep fd"
        read -rp "额外软件包: " PKG_INPUT
        
        if [[ -n "$PKG_INPUT" ]]; then
        read -ra EXTRA_PKGS <<< "$PKG_INPUT"
        info "将注入以下额外软件: ${EXTRA_PKGS[*]}"
        else
        info "未指定额外软件，使用仓库默认软件列表"
        fi
fi

# ============================================
# 磁盘选择与确认
# ============================================
echo ""
info "可用磁盘设备:"
lsblk -d -o NAME,SIZE,MODEL,TRAN | grep -v "^NAME" | awk '{printf "  /dev/%-12s %8s  %s\n", $1, $2, substr($0, index($0,$3))}'
read -rp "请输入目标磁盘 (如 /dev/nvme0n1): " DISK
[[ -b "$DISK" ]] || err "$DISK 不是有效的块设备"

warn "即将清除 $DISK 上的 EFI + Btrfs 根分区！"
read -rp "确认继续？(输入 YES): " confirm
[[ "$confirm" == "YES" ]] || { info "已取消"; exit 0; }

# ============================================
# 分区 & 格式化 & 挂载
# ============================================
info "创建分区并格式化..."
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart ESP fat32 1MiB 512MiB
parted -s "$DISK" set 1 esp on
parted -s "$DISK" mkpart primary btrfs 512MiB 100%
ESP="${DISK}p1"; ROOT="${DISK}p2"
udevadm settle && sleep 2

mkfs.fat -F32 -n EFI "$ESP"
mkfs.btrfs -L nixos -f "$ROOT"
mount "$ROOT" /mnt && mkdir -p /mnt/boot && mount "$ESP" /mnt/boot

# ============================================
# 克隆仓库 & 生成硬件配置
# ============================================
info "克隆配置仓库..."
TMP_CONFIG=$(mktemp -d)
git clone "$REPO_URL" "$TMP_CONFIG"
grep -q "\"${HOSTNAME}\"" "$TMP_CONFIG/flake.nix" || err "flake.nix 中未找到 hostname '$HOSTNAME'"

info "生成当前硬件配置..."
nixos-generate-config --show-hardware-config > "$TMP_CONFIG/hardware-configuration.nix"

# ============================================
# [自定义模式] 替换用户名
# ============================================
if [[ "$INSTALL_MODE" == "2" && "$TARGET_USER" != "$DEFAULT_USER" ]]; then
        info "替换用户名: $DEFAULT_USER → $TARGET_USER"
        sed -i "s/\b${DEFAULT_USER}\b/${TARGET_USER}/g" "$TMP_CONFIG/flake.nix"
        find "$TMP_CONFIG" -type f \( -name "*.nix" -o -name "*.kdl" -o -name "*.ini" \) \
        -exec sed -i "s|/home/${DEFAULT_USER}|/home/${TARGET_USER}|g" {} +
        ok "用户名替换完成"
fi

# ============================================
# [自定义模式] 自动扫描并替换 NTFS UUID
# ============================================
if [[ "$INSTALL_MODE" == "2" ]]; then
        info "扫描本机 NTFS 分区..."
        mapfile -t NTFS_PARTS < <(
        blkid -t TYPE=ntfs -o device 2>/dev/null | while read dev; do
        size=$(blockdev --getsize64 "$dev" 2>/dev/null || echo 0)
        echo "$size $dev"
        done | sort -rn | awk '{print $2}'
        )

        OLD_UUID_C="752A6785456870B8"
        OLD_UUID_D="4A9ED0D09ED0B5A3"

        if [[ ${#NTFS_PARTS[@]} -ge 2 ]]; then
        NEW_UUID_C=$(blkid -s UUID -o value "${NTFS_PARTS[0]}")
        NEW_UUID_D=$(blkid -s UUID -o value "${NTFS_PARTS[1]}")
        info "NTFS 分区映射:"
        echo "  /home/$TARGET_USER/C → ${NTFS_PARTS[0]} ($NEW_UUID_C)"
        echo "  /home/$TARGET_USER/D → ${NTFS_PARTS[1]} ($NEW_UUID_D)"
        sed -i "s/${OLD_UUID_C}/${NEW_UUID_C}/g" "$TMP_CONFIG/flake.nix"
        sed -i "s/${OLD_UUID_D}/${NEW_UUID_D}/g" "$TMP_CONFIG/flake.nix"
        ok "UUID 替换成功"
        else
        warn "未找到足够 NTFS 分区，保留原始 UUID"
        fi
fi

# ============================================
# [自定义模式] 注入额外软件包
# ============================================
if [[ "$INSTALL_MODE" == "2" && ${#EXTRA_PKGS[@]} -gt 0 ]]; then
        info "向 environment.systemPackages 注入额外软件..."
        
        # 构建要插入的 nix 表达式片段
        INJECT_LINES=""
        for pkg in "${EXTRA_PKGS[@]}"; do
        INJECT_LINES+="              pkgs.${pkg}\n"
        done
        
        # 在 systemPackages 列表的第一个元素前插入额外软件
        # 匹配 "# 基础工具与终端" 注释作为锚点，确保插入位置正确
        sed -i "/# 基础工具与终端/a\\${INJECT_LINES}" "$TMP_CONFIG/flake.nix"
        
        if grep -q "pkgs.${EXTRA_PKGS[0]}" "$TMP_CONFIG/flake.nix"; then
        ok "成功注入 ${#EXTRA_PKGS[@]} 个额外软件包"
        else
        warn "软件包注入可能失败，请安装后检查 flake.nix"
        fi
fi

# ============================================
# 安装 NixOS & 部署配置
# ============================================
info "开始安装 NixOS (首次构建可能需要 10-30 分钟)..."
nixos-install --flake "$TMP_CONFIG#${HOSTNAME}" --no-root-password --impure

info "复制配置到目标系统..."
rm -rf /mnt/etc/nixos
cp -a "$TMP_CONFIG" /mnt/etc/nixos
chown -R "$(id -u "$TARGET_USER" 2>/dev/null || echo 1000):100" /mnt/etc/nixos

# ============================================
# 完成提示
# ============================================
echo -e "\n${GREEN}=========================================="
echo "  ✅ NixOS 安装完成！"
echo -e "==========================================${NC}\n"
echo "📋 后续步骤:"
echo "  1. reboot 并拔掉 USB"
echo "  2. 首次登录设置密码: passwd $TARGET_USER"
echo "  3. cd /etc/nixos && git add -A && git commit -m 'chore: personalized install'"
echo "  4. 日常更新: sudo nixos-rebuild switch --flake .#nixos"
