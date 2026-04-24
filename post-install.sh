#!/usr/bin/bash
: '
此脚本适用于ArchLinux中使用
系统安装后安装一些必要组件
'

source common.sh

# 检查是否为root用户    
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}请以root用户运行此脚本。${NC}"
    exit 1
fi



# 检查是否已经添加了alias ll="ls -al",如果没有添加则添加
if ! grep -q 'alias ll="ls -al"' /etc/bash.bashrc; then
    echo 'alias ll="ls -al"' >> /etc/bash.bashrc
fi


# 设置时区为上海,并且同步时间
echo -e "${GREEN}正在设置时区为上海...${NC}"
timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp true

# 更新软件包列表
echo -e "${GREEN}正在更新软件包列表...${NC}"
pacman -Sy

# 将当系统语言设置为中文简体，且安装字体
echo -e "${GREEN}正在设置系统语言为中文简体...${NC}"
localectl set-locale LANG=zh_CN.UTF-8
FONTS=('fc-cache' 'noto-fonts' 'noto-fonts-cjk' 'noto-fonts-emoji' 'ttf-jetbrains-mono' 'adobe-source-code-pro-fonts')
echo -e "${GREEN}正在安装字体...${NC}"
for font in "${FONTS[@]}"; do
    pacman -S --noconfirm "$font"
done
fc-cache -fv


# 安装openssh,且修改配置文件PermitRootLogin为yes
echo -e "${GREEN}正在安装openssh...${NC}"
pacman -S --noconfirm openssh
echo -e "${GREEN}正在修改ssh配置文件...${NC}"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# 启动ssh服务
echo -e "${GREEN}正在启动ssh服务...${NC}"
systemctl enable --now sshd


# 安装sudo,且创建用户并添加到sudoers文件中,如果用户已存在跳过创建过程
echo -e "${GREEN}正在安装sudo...${NC}"
pacman -S --noconfirm sudo
read -p "请输入用户名: " USERNAME
if id "$USERNAME" &>/dev/null; then
    echo -e "${YELLOW}用户 $USERNAME 已存在。${NC}"
else
    echo -e "${GREEN}正在创建用户...${NC}"
    useradd -m -G wheel "$USERNAME"
    echo -e "${GREEN}正在设置用户密码...${NC}"
    passwd "$USERNAME"
    echo -e "${GREEN}正在添加用户到sudoers文件中...${NC}"
    echo "$USERNAME ALL=(ALL) ALL" >> /etc/sudoers
fi



# TODO安装音频组件
echo -e "${GREEN}正在安装音频组件...${NC}"
pacman -S --noconfirm pipewire pipewire-alsa wireplumber sof-firmware
systemctl --user enable --now pipewire



# 安装fcitx5,并且设置环境变量
# TODO 主题配置
echo -e "${GREEN}正在安装fcitx5...${NC}"
pacman -S --noconfirm fcitx5 fcitx5-chinese-addons
echo -e "${GREEN}正在设置环境变量...${NC}"
if ! grep -q "export GTK_IM_MODULE=fcitx" /etc/profile.d/fcitx5.sh; then
    echo "export GTK_IM_MODULE=fcitx" >> /etc/profile.d/fcitx5.sh
fi
if ! grep -q "export QT_IM_MODULE=fcitx" /etc/profile.d/fcitx5.sh; then
    echo "export QT_IM_MODULE=fcitx" >> /etc/profile.d/fcitx5.sh
fi
if ! grep -q "export XMODIFIERS=@im=fcitx" /etc/profile.d/fcitx5.sh; then
    echo "export XMODIFIERS=@im=fcitx" >> /etc/profile.d/fcitx5.sh
fi
if ! grep -q "export SDL_IM_MODULE=fcitx" /etc/profile.d/fcitx5.sh; then
    echo "export SDL_IM_MODULE=fcitx" >> /etc/profile.d/fcitx5.sh
fi


# firefox
echo -e "${GREEN}所有操作完成！${NC}"