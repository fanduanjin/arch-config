#!/usr/bin/bash
: ' 
定义一些常用的颜色变量
'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' 

info() {
    echo -e "${GREEN}$1${NC}"
}

warn() {
    echo -e "${YELLOW}$1${NC}"
}

error() {
    echo -e "${RED}$1${NC}"
}



: '
参数1: 配置项名
参数2: 配置项值
参数3: 文件路径
参数4: key_value分隔符,默认为=
所有参数做非空检查
参数3 检查路径文件是否存在，不存在则创建
配置项存在则覆盖,不存在则添加,考虑#注释情况
'
replace_key_value(){
    local key="$1"
    local value="$2"
    local file="$3"
    local sep="${4:-=}"
    
    if [[ -z "$key" || -z "$value" || -z "$file" ]]; then
        error "所有参数必须非空 参数1: 配置项名 参数2: 配置项值 参数3: 文件路径 参数4: key_value分隔符,默认为="
        return 1
    fi
    
    # 创建目录（如果需要）
    mkdir -p "$(dirname "$file")"
    
    # 创建文件（如果不存在）
    touch "$file"
    
    # 检查配置项是否存在（可能被注释）
    if grep -q "^#*$key$sep" "$file"; then
        # 替换现有项
        sed -i "s|^#*$key$sep.*|$key$sep$value|" "$file"
    else
        # 添加新项
        echo "$key$sep$value" >> "$file"
    fi
}



replace_key_value 'alias ll="ls -al"' "#" "/etc/profile.d/test.sh" '#'