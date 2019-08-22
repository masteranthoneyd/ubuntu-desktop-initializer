#!/bin/bash

######################## common env ########################

shopt -s expand_aliases
alias papti="sudo proxychains4 apt install -y"
alias pcurl="proxychains4 curl"
alias pwget="proxychains4 wget"

HOME_DIR="/home/${USER}"
WORK_DIR="${HOME_DIR}/data"
DOCKER_DIR="${WORK_DIR}/docker"
APP_DIR="${WORK_DIR}/application"


######################## install.sh env ########################
DOCKER_MIRRORS="https://vioqnt7w.mirror.aliyuncs.com"

# sudo 权限密码
PASSWORD="YOUR_PASSWORD"

# Shadowsocks ip
SS_IP="YOUR_SS_SERVER_IP"
# Shadowsocks 端口
SS_PORT="YOUR_SS_SERVER_PORD"
# Shadowsocks 密码
SS_PASSWORD="YOUR_SS_SERVER_PASSWORD"

# git 信息配置
GIT_USER_NAME="YOUR_GIT_USER"
GIT_USER_EMAIL="YOUR_GIT_EMAIL"

############ 是否在执行install.sh的时候执行对应脚本 ####### 
# 是否执行 theme.sh
ENABLE_THEME=true
# 是否执行 dev_env.sh
ENABLE_DEV_ENV=false
# 是否执行 commom_soft.sh
ENABLE_COMMON_SOFT=false
# 是否执行 hexo.sh
ENABLE_HEXO=false

function _check_SS() {
    nc -z -v -w3 ${SS_IP} ${SS_PORT}
    result=$?
    if [[ "${result}" != 0 ]]; then
        echo "SS server port close!"
        exit 1
    fi
}

_check_SS


######################## theme.sh env ########################

# 配置主题, 可选: Sweet, Sierra
SYS_THEME=Sweet


######################## dev_env.sh ########################

# 是否安装并启动Kafka(连带Zookeeper)
UP_KAFKA=false

# 是否启用RabbitMQ
UP_RABBITMQ=false

# Navicat 下载, 可选: native, crack
NAVICAT=crack

NAVICAT_CRACK_RESOURCE=cdn
