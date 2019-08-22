#!/bin/bash
set -e
source env.sh

SS_DIR="${APP_DIR}/shadowsocks"

function _genpac() {
    # pip3
    papti python3-widgetsnbextension python3-testresources python3-distutils
    pcurl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    sudo proxychains4 python3 get-pip.py
    rm get-pip.py
    sudo proxychains4 pip install --upgrade virtualenv

    # GenPAC 全局代理
    sudo proxychains4 pip install genpac
    mkdir -p ${SS_DIR}
    genpac --proxy="SOCKS5 127.0.0.1:1080" -o ${SS_DIR}/autoproxy.pac --gfwlist-url="https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt"

    cat <<- EOF


################################################
##                                            ##
##          Genpac Install Success!           ##
##                                            ##
################################################

EOF
    sleep 1
}

function _chrome() {
    SWITCHY_OMEGA_URL=""
    for row in $(wget -qO - https://api.github.com/repos/FelisCatus/SwitchyOmega/releases/latest | jq -c -r '.assets[]'); do
        SWITCHY_OMEGA=`echo ${row} | jq -r '.name'`
        if [[ ${SWITCHY_OMEGA} == SwitchyOmega_Chromium.crx ]]; then
            SWITCHY_OMEGA_URL=`echo ${row} | jq -r '.browser_download_url'`
            echo "SwitchyOmega release url is ${SWITCHY_OMEGA_URL}"
            break
        fi
    done
    mkdir -p ${APP_DIR}/chrome
    pwget -O ${APP_DIR}/chrome/SwitchyOmega_Chromium.crx ${SWITCHY_OMEGA_URL}
    pwget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo gdebi -n google-chrome-stable_current_amd64.deb
    rm google-chrome-stable_current_amd64.deb
    cat <<- EOF


################################################
##                                            ##
##          Chrome Install Success!           ##
##                                            ##
################################################

EOF
    sleep 1
}

function _timeshift() {
    sudo proxychains4 add-apt-repository -y ppa:teejee2008/ppa
    papti timeshift
    cat <<- EOF


################################################
##                                            ##
##        Timeshift Install Success!          ##
##                                            ##
################################################

EOF
    sleep 1
}

function _dingtalk() {
    DINGTALK_NAME=""
    DINGTALK_URL=""
    for row in $(wget -qO - https://api.github.com/repos/nashaofu/dingtalk/releases/latest | jq -c -r '.assets[]'); do
        DINGTALK_NAME=`echo ${row} | jq -r '.name'`
        if [[ ${DINGTALK_NAME} =~ "amd64.deb" ]]; then
            DINGTALK_URL=`echo ${row} | jq -r '.browser_download_url'`
            echo "Dingtalk release url is ${DINGTALK_URL}"
            break
        fi
    done
    pwget ${DINGTALK_URL}
    sudo proxychains4 gdebi -n ${DINGTALK_NAME}
    rm ${DINGTALK_NAME}
    cat <<- EOF


################################################
##                                            ##
##         Dingtalk Install Success!          ##
##                                            ##
################################################

EOF
    sleep 1
}

function _peek() {
    sudo proxychains4 add-apt-repository -y ppa:peek-developers/stable
    papti peek
}

function _wps() {
    wget http://kdl.cc.ksosoft.com/wps-community/download/6757/wps-office_10.1.0.6757_amd64.deb
    sudo gdebi -n wps-office_10.1.0.6757_amd64.deb
    rm wps-office_10.1.0.6757_amd64.deb
    cat <<- EOF


################################################
##                                            ##
##            WPS Install Success!            ##
##                                            ##
################################################

EOF
    sleep 1
}

function _typora() {
    pwget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
    sudo proxychains4 add-apt-repository -y 'deb https://typora.io/linux ./'
    papti typora
    cat <<- EOF


################################################
##                                            ##
##          Typora Install Success!           ##
##                                            ##
################################################

EOF
    sleep 1
}

function _fronting() {
    papti cmatrix
    mkdir -p ${APP_DIR}/edex-ui

    EDEX_NAME=""
    EDEX_URL=""
    for row in $(wget -qO - https://api.github.com/repos/GitSquared/edex-ui/releases/latest | jq -c -r '.assets[]'); do
        EDEX_NAME=`echo ${row} | jq -r '.name'`
        if [[ ${EDEX_NAME} =~ x86_64 ]]; then
            EDEX_URL=`echo ${row} | jq -r '.browser_download_url'`
            echo "Edex-UI release url is ${EDEX_URL}"
            break
        fi
    done
    pwget -P ${APP_DIR}/edex-ui ${EDEX_URL}
    chmod +x ${APP_DIR}/edex-ui/${EDEX_NAME}
}

function _shutter() {
    pwget https://launchpad.net/ubuntu/+archive/primary/+files/libgoocanvas-common_1.0.0-1_all.deb
    sudo gdebi -n libgoocanvas-common_1.0.0-1_all.deb
    rm libgoocanvas-common_1.0.0-1_all.deb

    pwget https://launchpad.net/ubuntu/+archive/primary/+files/libgoocanvas3_1.0.0-1_amd64.deb
    sudo gdebi -n libgoocanvas3_1.0.0-1_amd64.deb
    rm libgoocanvas3_1.0.0-1_amd64.deb

    pwget https://launchpad.net/ubuntu/+archive/primary/+files/libgoo-canvas-perl_0.06-2ubuntu3_amd64.deb
    sudo gdebi -n libgoo-canvas-perl_0.06-2ubuntu3_amd64.deb
    rm libgoo-canvas-perl_0.06-2ubuntu3_amd64.deb

    papti shutter
    dconf load /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ <<- EOF
[custom0]
binding='<Primary><Shift><Alt>a'
command='shutter -s'
name='shutter'
EOF
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
    cat <<- EOF


################################################
##                                            ##
##             Shutter Installed!             ##
##                                            ##
################################################

EOF
    sleep 1
}

function _teamviewer() {
    pwget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
    sudo proxychains4 gdebi -n teamviewer_amd64.deb
    rm teamviewer_amd64.deb
}

function _kvm() {
    SUPPORT_KVM=$(egrep -c '(svm|vmx)' /proc/cpuinfo | cat)
    if [[ ${SUPPORT_KVM} == "0" ]]; then
        echo "Not support KVM!!!"
        return
    fi
    papti qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils virt-manager virtinst virt-viewer
    cat <<- EOF


################################################
##                                            ##
##              KVM Installed!                ##
##                                            ##
################################################

EOF
    sleep 1
}

function _sogou() {
    mkdir -p ${HOME_DIR}/.config
    sudo apt purge -y ibus
    sudo  apt remove -y indicator-keyboard
    papti fcitx-table-wbpy fcitx-config-gtk
    im-config -n fcitx
    wget http://cdn2.ime.sogou.com/dl/index/1524572264/sogoupinyin_2.2.0.0108_amd64.deb
    sudo proxychains4 gdebi -n sogoupinyin_2.2.0.0108_amd64.deb
    rm sogoupinyin_2.2.0.0108_amd64.deb
    tar -xJf ./config/fcitx.tar.xz -C ${HOME_DIR}/.config/
    tar -xJf ./config/SogouPY.tar.xz -C ${HOME_DIR}/.config/
    cat <<- EOF


################################################
##                                            ##
##              Sogou Installed!              ##
##                                            ##
################################################

EOF
    sleep 1
}

function _aria2_ariaNg() {
    sudo docker-compose -f ${DOCKER_DIR}/aria2/docker-compose.yml up -d
    mkdir -p ${APP_DIR}/BaiduExporter
    proxychains4 git clone https://github.com/acgotaku/BaiduExporter.git ${APP_DIR}/BaiduExporter
    cat <<- EOF


################################################
##                                            ##
##                 Aria2 Up!                  ##
##                                            ##
################################################

EOF
    sleep 1
}

function _scrt() {
    mkdir -p ${APP_DIR}/scrt
    papti perl
    wget https://cdn.yangbingdong.com/resource/scrt/scrt-8.5.3-1867.ubuntu18-64.x86_64.deb
    sudo gdebi -n scrt-8.5.3-1867.ubuntu18-64.x86_64.deb
    wget http://download.boll.me/securecrt_linux_crack.pl
    sudo perl securecrt_linux_crack.pl /usr/bin/SecureCRT > ${APP_DIR}/scrt/license.txt
    rm scrt-8.5.3-1867.ubuntu18-64.x86_64.deb securecrt_linux_crack.pl
    cat <<- EOF


################################################
##                                            ##
##              Scrt Installed!               ##
##                                            ##
################################################

EOF
    sleep 1
}

function _deepwine() {
    git clone https://gitee.com/wszqkzqk/deepin-wine-for-ubuntu.git
    cd ./deepin-wine-for-ubuntu
    ./install.sh
    cd ..
    rm -rf ./deepin-wine-for-ubuntu
    sudo apt install libjpeg62:i386 libxtst6:i386
    wget https://mirrors.aliyun.com/deepin/pool/non-free/d/deepin.com.wechat/deepin.com.wechat_2.6.2.31deepin0_i386.deb
    sudo dpkg -i deepin.com.wechat_2.6.2.31deepin0_i386.deb
    rm deepin.com.wechat_2.6.2.31deepin0_i386.deb
    wget https://mirrors.aliyun.com/deepin/pool/non-free/d/deepin.com.weixin.work/deepin.com.weixin.work_2.4.16.1347deepin1_i386.deb
    sudo dpkg -i deepin.com.weixin.work_2.4.16.1347deepin1_i386.deb
    rm deepin.com.weixin.work_2.4.16.1347deepin1_i386.deb
    cat <<- EOF


################################################
##                                            ##
##           Deepwine Installed               ##
##                                            ##
################################################

EOF
    sleep 1
}

_genpac
_chrome
_timeshift
_dingtalk
_peek
_wps
_typora
_fronting
_shutter
_teamviewer
_kvm
_sogou
_aria2_ariaNg
_scrt
_deepwine