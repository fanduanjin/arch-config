#!/usr/bin/bash
: '
安装用户层组件
'
source common.sh


# 安装AUR助手yay
if ! command -v yay &> /dev/null; then
    info "正在安装AUR助手yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
else
    info "AUR助手yay已安装。"
fi
