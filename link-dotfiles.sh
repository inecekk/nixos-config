#!/usr/bin/env bash
# ==========================================
# 跨发行版 (NixOS / Arch Linux) .config 铺设脚本
# ==========================================

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_DIR="$REPO_DIR/.config"

echo "🔗 开始将 $CONFIG_DIR 中的配置建立软链接至 ~/.config ..."

mkdir -p "$HOME/.config"

# 需要纳管的配置文件夹列表
configs=("niri" "foot" "btop" "fcitx5" "cava" "go-musicfox" "pcmanfm")

for item in "${configs[@]}"; do
  target="$HOME/.config/$item"
  source="$CONFIG_DIR/$item"

  if [ -d "$source" ]; then
    # 建立软链接（-f 强制覆盖，-n 避免目录嵌套）
    ln -sfn "$source" "$target"
    echo "✅ 已建立链接: ~/.config/$item -> $source"
  fi
done

echo "🎉 部署完成！"
