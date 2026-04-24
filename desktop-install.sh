#!/usr/bin/bash
: '
此脚本用于安装桌面环境
- 窗口管理器: Sway
- 状3态栏: Waybar
- 应用程序启动器: Wofi
- 文件管理器: Yazi
- 终端模拟器: Kitty
- 截图工具: grim slurp swappy
'
source ./common.sh

info "正在安装桌面环境..."
# 检查stow是否安装,如果没有安装则安装
if ! command -v stow &> /dev/null; then
    info "正在安装stow..."
    pacman -S --noconfirm stow
fi


# 安装所需包
PACKAGES="sway swaybg waybar wofi yazi kitty fastfetch grim slurp swappy"
pacman -S --noconfirm $PACKAGES
info " ${PACKAGES} 安装完毕..."

info "更新stow目录..."
declare -A STOW_DIRS=(
    ["/etc/sway"]="sway"
    ["/etc/xdg/kitty"]="kitty"  
    ["/etc/xdg/waybar"]="waybar"
)


for target_dir in "${!STOW_DIRS[@]}"; do
    package_name="${STOW_DIRS[$target_dir]}"
    rm -rf "$target_dir"
    #if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    #fi
    stow  -t "$target_dir" -R "$package_name"
done


 
info "安装完毕..."


