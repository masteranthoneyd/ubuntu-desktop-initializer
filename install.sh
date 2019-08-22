#!/bin/bash
set -e
source env.sh

function _system_init_setting()
{
    # 修改root密码
    echo "root:${PASSWORD}" | sudo -S chpasswd root <<- EOF
${PASSWORD}
EOF

    # 修改默认编辑器为vim（默认为nano）
    sudo update-alternatives --set editor /usr/bin/vim.tiny

    # sudo 不需要密码
    echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/sudoers

    # 关闭自动锁屏
    gsettings set org.gnome.desktop.session idle-delay 0

    # windows双系统同一时间
    timedatectl set-local-rtc 1 --adjust-system-clock

    cat <<- EOF


################################################
##                                            ##
##           System Setting Done!             ##
##                                            ##
################################################


EOF
    sleep 2
}

# Docker
function _install_docker() {
    sudo apt install -y curl apt-transport-https ca-certificates gnupg-agent software-properties-common
    ## 使用Ali镜像
    curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository -y "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt install -y docker-ce
    ## 将当前用户添加到docker用户组, 重启后生效
    sudo usermod -aG docker ${USER}
    sudo mkdir -p /etc/docker
    ## 使用Ali镜像
    sudo tee /etc/docker/daemon.json <<- EOF
{
  "registry-mirrors": ["${DOCKER_MIRRORS}"]
}
EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker

    cat <<- EOF


################################################
##                                            ##
##          Docker Install Completed!         ##
##                                            ##
################################################


EOF
    sleep 2
}

# 代理
function _proxy() {
    # 开启TCP Fast Open
    echo "net.ipv4.tcp_fastopen = 3" | sudo tee -a /etc/sysctl.conf
    echo "3" | sudo tee /proc/sys/net/ipv4/tcp_fastopen
    sudo sysctl -p

    sudo docker pull mritd/shadowsocks:latest
    sudo docker run -dt --name ssclient --restart=always -p 1080:1080 mritd/shadowsocks:latest -m "ss-local" -s "-s ${SS_IP} -p ${SS_PORT} -b 0.0.0.0 -l 1080 -m aes-256-cfb -k ${SS_PASSWORD} --fast-open"

    # proxychains4
    sudo apt install -y gcc make
    wget -O proxychians-ng.tar.gz https://github.com/rofl0r/proxychains-ng/archive/v4.13.tar.gz
    mkdir proxychians-ng
    tar -zxf proxychians-ng.tar.gz -C proxychians-ng --strip-components 1
    rm proxychians-ng.tar.gz
    cd proxychians-ng
    ./configure --prefix=/usr --sysconfdir=/etc
    make
    sudo make install
    sudo make install-config
    cd ../
    rm -rf proxychians-ng
    sudo sed -i 's/^socks4.*9050$/socks5  127.0.0.1 1080/' /etc/proxychains.conf
    sudo sed -i 's/\#quiet_mode/quiet_mode/' /etc/proxychains.conf

    # config privoxy
    sudo apt install -y privoxy
    sudo sed -i 's/listen-address  127.0.0.1:8118/listen-address  0.0.0.0:8118/' /etc/privoxy/config
    echo "forward-socks5 / 127.0.0.1:1080 ." | sudo tee -a /etc/privoxy/config
    sudo /etc/init.d/privoxy restart

    cat <<- EOF


################################################
##                                            ##
##          Proxy Install Completed!          ##
##                                            ##
################################################


EOF
    sleep 2
}

function _docker_compose() {
    papti jq
    # 获取最新的 release 版本
    DOCKER_COMPOSE_URL=""
    for row in $(wget -qO - https://api.github.com/repos/docker/compose/releases/latest | jq -c -r '.assets[]'); do
        DOCKER_COMPOSE=`echo ${row} | jq -r '.name'`
        if [[ ${DOCKER_COMPOSE} == docker-compose-Linux-x86_64 ]]; then
            DOCKER_COMPOSE_URL=`echo ${row} | jq -r '.browser_download_url'`
            echo "Docker Compose release url is ${DOCKER_COMPOSE_URL}"
            break
        fi
    done
    sudo proxychains4 wget -q ${DOCKER_COMPOSE_URL} -O /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    cat <<- EOF


################################################
##                                            ##
##      Docker Compose Install Completed!     ##
##                                            ##
################################################


EOF
    sleep 2
}

function _down_my_docker_compose() {
    mkdir -p ${DOCKER_DIR}
    pwget -L -O ${DOCKER_DIR}/docker-compose-related-master.zip https://codeload.github.com/masteranthoneyd/docker-compose-related/zip/master
    unzip -d ${DOCKER_DIR} ${DOCKER_DIR}/docker-compose-related-master.zip
    mv ${DOCKER_DIR}/docker-compose-related-master/* ${DOCKER_DIR}/
    rm -rf ${DOCKER_DIR}/docker-compose-related-master ${DOCKER_DIR}/docker-compose-related-master.zip
    rm -rf ${DOCKER_DIR}/script4ubuntu/.git
    rm -rf ${DOCKER_DIR}/script4ubuntu/.idea
    rm -rf ${DOCKER_DIR}/script4ubuntu/.gitignore
    cat <<- EOF


################################################
##                                            ##
##    Downloaded My Docker Compose Relate     ##
##                                            ##
################################################


EOF
    sleep 2
}

function _system_soft() {
    # 升级
    sudo proxychains4 apt upgrade -y
    cat <<- EOF


################################################
##                                            ##
##              Upgrade Success!              ##
##                                            ##
################################################


EOF
    sleep 2

    papti git net-tools gdebi ssh curl snapd exfat-fuse exfat-utils screenfetch

    git config --global user.name "${GIT_USER_NAME}"
    git config --global user.email "${GIT_USER_EMAIL}"

    # 配置 snap 代理
    sudo mkdir -p /etc/systemd/system/snapd.service.d
    sudo tee /etc/systemd/system/snapd.service.d/override.conf <<- EOF
[Service]
Environment=http_proxy=http://127.0.0.1:8118
Environment=https_proxy=http://127.0.0.1:8118
EOF
    sudo systemctl daemon-reload
    sudo systemctl restart snapd.service

    # 安装 zsh, oh-my-zsh, 重启后生效
    papti zsh
    sudo chsh -s $(which zsh)
    echo "${PASSWORD}" | chsh -s $(which zsh)
    proxychains4 sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" <<- EOF
${PASSWORD}
EOF

    # 安装fast-apt
    papti aria2
    #/bin/bash X-c "$(curl -sL https://raw.githubusercontent.com/ilikenwf/apt-fast/master/quick-install.sh)"
    sudo proxychains4 wget https://raw.githubusercontent.com/ilikenwf/apt-fast/master/apt-fast -O /usr/local/sbin/apt-fast
    sudo chmod +x /usr/local/sbin/apt-fast
    if ! [[ -f /etc/apt-fast.conf ]]; then
        sudo proxychains4 wget https://raw.githubusercontent.com/ilikenwf/apt-fast/master/apt-fast.conf -O /etc/apt-fast.conf
        sudo sed -i 's/\#_APTMGR=apt-get/_APTMGR=apt/' /etc/apt-fast.conf
    fi
    cat <<- EOF


################################################
##                                            ##
##           System Soft Installed!           ##
##                                            ##
################################################


EOF
    sleep 2
}

function _alias() {
    cat <<- EOF >> ${HOME_DIR}/.zshrc
#############################
alias eproxy="export http_proxy=127.0.0.1:8118 && export https_proxy=127.0.0.1:8118"
alias apti="sudo apt install -y"
alias papti="sudo proxychains4 apt install -y"
alias pcurl="proxychains4 curl"
alias pwget="proxychains4 wget"
EOF
}

function _favorite_apps() {
gsettings set org.gnome.shell favorite-apps \
"['google-chrome.desktop', 'firefox.desktop', 'timeshift-gtk.desktop', 'dingtalk.desktop', 'org.gnome.tweaks.desktop', 'wps-office-wps.desktop', 'typora.desktop', 'com.teamviewer.TeamViewer.desktop', 'gnome-system-monitor_gnome-system-monitor.desktop', 'appimagekit-edex-ui.desktop', 'jetbrains-idea.desktop', 'virt-manager.desktop', 'redis-desktop-manager_rdm.desktop', 'postman.desktop', 'SecureCRT.desktop']"
}

# 主题安装以及配置
function _theme() {
    if [[ ${ENABLE_THEME} == "true" ]] && [[ -f ./theme.sh ]]; then
        ./theme.sh
    fi
}

function _dev_soft() {
    if [[ ${ENABLE_DEV_ENV} == "true" ]] && [[ -f ./dev_env.sh ]]; then
        ./dev_env.sh
    fi
}

function _common_soft() {
    if [[ ${ENABLE_COMMON_SOFT} == "true" ]] && [[ -f ./common_soft.sh ]]; then
        ./common_soft.sh
    fi
}

function _hexo() {
    if [[ ${ENABLE_HEXO} == "true" ]] && [[ -f ./hexo.sh ]]; then
        ./hexo.sh
    fi
}

# 自动补全
function _auto_completion() {
    ## apt-fast
    mkdir -p ${HOME_DIR}/.oh-my-zsh/completions
    wget -O ${HOME_DIR}/.oh-my-zsh/completions/_apt-fast https://raw.githubusercontent.com/ilikenwf/apt-fast/master/completions/zsh/_apt-fast
    ## docker compose
    pwget -q https://raw.githubusercontent.com/docker/compose/$(docker-compose version --short)/contrib/completion/zsh/_docker-compose -O ${HOME_DIR}/.oh-my-zsh/completions/_docker-compose
    ## 语法高亮下载
    proxychains4 git clone git://github.com/zsh-users/zsh-syntax-highlighting.git ${HOME_DIR}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    ## oh-my-zsh 插件: git, 高亮, golang
    sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting go)/' ${HOME_DIR}/.zshrc
}



_system_init_setting
_install_docker
_proxy
_docker_compose
_down_my_docker_compose
_system_soft
_alias
_theme
_dev_soft
_common_soft
_hexo
_favorite_apps
_auto_completion

sleep 1

cat <<- EOF

#  DDDDDDDDDDDDD
#  D::::::::::::DDD
#  D:::::::::::::::DD
#  DDD:::::DDDDD:::::D
#    D:::::D    D:::::D    ooooooooooo   nnnn  nnnnnnnn        eeeeeeeeeeee
#    D:::::D     D:::::D oo:::::::::::oo n:::nn::::::::nn    ee::::::::::::ee
#    D:::::D     D:::::Do:::::::::::::::on::::::::::::::nn  e::::::eeeee:::::ee
#    D:::::D     D:::::Do:::::ooooo:::::onn:::::::::::::::ne::::::e     e:::::e
#    D:::::D     D:::::Do::::o     o::::o  n:::::nnnn:::::ne:::::::eeeee::::::e
#    D:::::D     D:::::Do::::o     o::::o  n::::n    n::::ne:::::::::::::::::e
#    D:::::D     D:::::Do::::o     o::::o  n::::n    n::::ne::::::eeeeeeeeeee
#    D:::::D    D:::::D o::::o     o::::o  n::::n    n::::ne:::::::e
#  DDD:::::DDDDD:::::D  o:::::ooooo:::::o  n::::n    n::::ne::::::::e
#  D:::::::::::::::DD   o:::::::::::::::o  n::::n    n::::n e::::::::eeeeeeee
#  D::::::::::::DDD      oo:::::::::::oo   n::::n    n::::n  ee:::::::::::::e
#  DDDDDDDDDDDDD           ooooooooooo     nnnnnn    nnnnnn    eeeeeeeeeeeeee
#
# System Reboot After 10 Second

EOF

screenfetch

while(true)
do
        echo -n "."
        sleep 1
done &
BG_PID=$!
sleep 10
kill $BG_PID

sudo shutdown -r now
