#!/usr/bin/bash
: '
此脚本适用于ArchLinux中使用
系统安装后安装一些必要组件
'

source common.sh

# 检查是否为root用户    
if [ "$EUID" -ne 0 ]; then
    error "请以root用户运行此脚本。"
    exit 1
fi

# 添加alias ll="ls -al"到/etc/bash.bashrc中,如果已经添加则跳过
info "正在添加alias ll=\"ls -al\"到/etc/bash.bashrc中..."
replace_key_value 'alias ll="ls -al"' " " "/etc/bash.bashrc" ' '


# 设置时区为上海,并且同步时间
info "正在设置时区为上海..."
timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp true

# 更新软件包列表
info "正在更新软件包列表..."
pacman -Sy

# 将当系统语言设置为中文简体，且安装字体
info "正在设置系统语言为中文简体..."
localectl set-locale LANG=zh_CN.UTF-8
FONTS=('fc-cache' 'noto-fonts' 'noto-fonts-cjk' 'noto-fonts-emoji' 'ttf-jetbrains-mono' 'adobe-source-code-pro-fonts')
info "正在安装字体..."
for font in "${FONTS[@]}"; do
    pacman -S --noconfirm "$font"
done
fc-cache -fv


# 安装openssh,且修改配置文件PermitRootLogin为yes
info "正在安装openssh..."
pacman -S --noconfirm openssh
info "正在修改ssh配置文件..."
replace_key_value 'PermitRootLogin' 'yes' '/etc/ssh/sshd_config' ' '
# 启动ssh服务
info "正在启动ssh服务..."
systemctl enable --now sshd


# 安装sudo,且创建用户并添加到sudoers文件中,如果用户已存在跳过创建过程
info "正在安装sudo..."
pacman -S --noconfirm sudo
read -p "请输入用户名: " USERNAME
if id "$USERNAME" &>/dev/null; then
    info "用户 $USERNAME 已存在。"
else
    info "正在创建用户..."
    useradd -m -G wheel "$USERNAME"
    info "正在设置用户密码..."
    passwd "$USERNAME"
    info "正在添加用户到sudoers文件中..."
    echo "$USERNAME ALL=(ALL) ALL" >> /etc/sudoers
fi



# TODO安装音频组件
info "正在安装音频组件..."
pacman -S --noconfirm pipewire pipewire-alsa wireplumber sof-firmware
systemctl --user enable --now pipewire



# 安装fcitx5,并且设置环境变量
# TODO 主题配置
info "正在安装fcitx5..."
pacman -S --noconfirm fcitx5 fcitx5-chinese-addons
info "正在设置环境变量..."
replace_key_value 'export GTK_IM_MODULE=fcitx' ' ' "/etc/profile.d/fcitx5.sh" ' '
replace_key_value 'export QT_IM_MODULE=fcitx' ' ' "/etc/profile.d/fcitx5.sh" ' '
replace_key_value 'export XMODIFIERS=@im=fcitx' ' ' "/etc/profile.d/fcitx5.sh" ' '
replace_key_value 'export SDL_IM_MODULE=fcitx' ' ' "/etc/profile.d/fcitx5.sh" ' '


# done
info "所有操作完成！"