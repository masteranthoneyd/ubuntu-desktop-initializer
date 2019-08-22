#!/bin/bash
set -e
source env.sh

function gnome_shell_extension() {
    # 启用 User Theme
    gnome-shell-extension-tool -e user-theme@gnome-shell-extensions.gcampax.github.com
    gsettings set org.gnome.shell.extensions.user-theme name "Sweet"
    # 左上角的文件夹入口
    gnome-shell-extension-tool -e places-menu@gnome-shell-extensions.gcampax.github.com
    # 驱动图标
    gnome-shell-extension-tool -e drive-menu@gnome-shell-extensions.gcampax.github.com
    # open weather
    papti gnome-shell-extension-weather
    gnome-shell-extension-tool -e openweather-extension@jenslody.de
    dconf load /org/gnome/shell/extensions/openweather/ <<- EOF
[/]
weather-provider='openweathermap'
center-forecast=true
days-forecast=2
unit='celsius'
geolocation-provider='openstreetmaps'
actual-city=0
use-default-owm-key=true
show-text-in-panel=true
show-comment-in-panel=true
location-text-length=0
position-in-panel='center'
wind-speed-unit='kph'
translate-condition=true
city='23.1301964,113.2592945>广州市, 广东省, 中国 >-1'
wind-direction=true
use-symbolic-icons=true
use-text-on-buttons=true
pressure-unit='Pa'
show-comment-in-forecast=true
decimal-places=1
EOF
    # dash-to-dock
#    proxychains4 git clone https://github.com/micheleg/dash-to-dock.git
#    cd dash-to-dock
#    make
#    make install
#    cd ../
#    rm -rf dash-to-dock/
    pwget https://extensions.gnome.org/review/download/9189.shell-extension.zip -O dash-to-dock@micxgx.gmail.com.zip
    mkdir -p ${HOME_DIR}/.local/share/gnome-shell/extensions
    unzip dash-to-dock@micxgx.gmail.com.zip -d ${HOME_DIR}/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/ && rm dash-to-dock@micxgx.gmail.com.zip
    gnome-shell-extension-tool -e dash-to-dock@micxgx.gmail.com
    dconf load /org/gnome/shell/extensions/dash-to-dock/ <<- EOF
[/]
preferred-monitor=0
show-apps-at-top=true
extend-height=true
dock-fixed=true
force-straight-corner=false
click-action='minimize-or-previews'
intellihide-mode='FOCUS_APPLICATION_WINDOWS'
hot-keys=false
multi-monitor=false
custom-background-color=false
max-alpha=0.80000000000000004
apply-custom-theme=false
isolate-monitors=false
dock-position='LEFT'
custom-theme-shrink=true
background-opacity=0.1
running-indicator-style='DEFAULT'
dash-max-icon-size=32
show-favorites=true
transparency-mode='FIXED'
icon-size-fixed=true
isolate-workspaces=true
running-indicator-style='DOTS'
EOF
    # TopIcons Plus
    proxychains4 git clone https://github.com/phocean/TopIcons-plus.git
    cd TopIcons-plus
    make install
    cd ../
    rm -rf TopIcons-plus/
    gnome-shell-extension-tool -e TopIcons@phocean.net
    dconf load /org/gnome/shell/extensions/topicons/ <<- EOF
[/]
icon-size=24
icon-spacing=12
tray-pos='right'
tray-order=1
EOF
    # Internet speed meter
    proxychains4 git clone https://gitlab.com/TH3L0N3C0D3R/Internet-Speed-Meter.git ${HOME_DIR}/.local/share/gnome-shell/extensions/Internet-Speed-Meter@TH3L0N3C0D3R
    gnome-shell-extension-tool -e Internet-Speed-Meter@TH3L0N3C0D3R
    # DynamicTopBar
    proxychains4 git clone https://github.com/AMDG2/GnomeShell_DynamicTopBar.git
    cd GnomeShell_DynamicTopBar
    ./install.sh
    cd ../
    rm -rf GnomeShell_DynamicTopBar
    dconf load /org/gnome/shell/extensions/dynamic-top-bar/ <<- EOF
[/]
show-activity=true
style='Transparency'
button-shadow=true
transparency-level=0.10000000000000001
EOF
    # System-monitor
    papti gir1.2-gtop-2.0 libgtop2-dev
    proxychains4 wget https://github.com/elvetemedve/gnome-shell-extension-system-monitor/releases/download/14/System_Monitor.bghome.gmail.com-14.zip
    unzip -d ${HOME_DIR}/.local/share/gnome-shell/extensions/System_Monitor@bghome.gmail.com System_Monitor.bghome.gmail.com-14.zip
    gnome-shell-extension-tool -e System_Monitor@bghome.gmail.com
    rm System_Monitor.bghome.gmail.com-14.zip

}

function _theme() {
    if [[ -d ./img ]]; then
        sudo cp -r ./img /usr/share/backgrounds/
    else
        echo "img folder not found!"
        exit 1
    fi

    # 主题美化依赖
    papti gnome-tweak-tool gnome-shell-extensions chrome-gnome-shell gtk2-engines-pixbuf libxml2-utils make dconf-editor ttf-ancient-fonts fonts-wqy-microhei

    # powerline 字体
    proxychains4 git clone https://github.com/powerline/fonts.git --depth=1
    ./fonts/install.sh
    rm -rf ./fonts

    ## robbyrussell 主题
    pwget -O ${HOME_DIR}/.oh-my-zsh/themes/bullet-train.zsh-theme http://raw.github.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="bullet-train"/' ${HOME_DIR}/.zshrc
    dconf load /org/gnome/terminal/ <<- EOF
[legacy/profiles:]
list=['b1dcc9dd-5262-4d8d-a863-c897e6d979b9']
[legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9]
foreground-color='rgb(0,255,0)'
cjk-utf8-ambiguous-width='narrow'
visible-name='my-profile'
cell-width-scale=1.0
default-size-columns=100
cursor-shape='ibeam'
scroll-on-output=false
use-theme-colors=false
use-system-font=false
use-transparent-background=true
font='Ubuntu Mono derivative Powerline 12'
use-theme-transparency=false
background-color='rgb(0,43,54)'
background-transparency-percent=10
[legacy]
schema-version=uint32 3
EOF

    case ${SYS_THEME} in
     Sierra)
        # Sierra-gtk-theme 系统主题
        sudo proxychains4 add-apt-repository -y ppa:dyatlov-igor/sierra-theme
        papti sierra-gtk-theme
        gsettings set org.gnome.desktop.interface gtk-theme Sierra-light
        gsettings set org.gnome.desktop.wm.preferences Sierra-light
        ;;
     Sweet)
        # Sweet 系统主题
        sudo tar -xJf ./theme/Sweet.tar.xz -C /usr/share/themes/ && rm -rf Sweet.tar.xz
        gsettings set org.gnome.desktop.interface gtk-theme Sweet
        gsettings set org.gnome.desktop.wm.preferences theme Sweet
        ;;
     *)
        echo "Please select a theme"
        exit 1
        ;;
    esac

    # Suru++ 图标
    proxychains4 sh -c "$(wget -qO- https://raw.githubusercontent.com/gusbemacbe/suru-plus/master/install.sh)"
    gsettings set org.gnome.desktop.interface icon-theme "Suru++"
    # 更换文件夹图标颜色
    proxychains4 sh -c "$(curl -fsSL https://raw.githubusercontent.com/gusbemacbe/suru-plus-folders/master/install.sh)"
    suru-plus-folders -C cyan --theme Suru++

    # 光标主题 Capitaine
    sudo proxychains4 add-apt-repository -y ppa:dyatlov-igor/la-capitaine
    papti la-capitaine-cursor-theme
    if [[ $? -eq 0 ]]; then
        echo "installed la-capitaine-cursor-theme"
    else
        echo "install la-capitaine-cursor-theme fail"
        exit 1
    fi
    gsettings set org.gnome.desktop.interface cursor-theme "Capitaine"

    # Grub 2
    sudo proxychains4 add-apt-repository -y ppa:danielrichter2007/grub-customizer
    papti grub-customizer
    proxychains4 git clone https://github.com/vinceliuice/grub2-themes.git
    papti dialog
    sudo ./grub2-themes/install.sh -t
    rm -rf grub2-themes
    sudo sed -i '/GRUB_TIMEOUT=/c\GRUB_TIMEOUT=10' /etc/default/grub
    sudo sed -i 's/GRUB_TIMEOUT_STYLE=/#GRUB_TIMEOUT_STYLE=/' /etc/default/grub
    sudo update-grub2

    # 背景图
    gsettings set org.gnome.desktop.background picture-uri "/usr/share/backgrounds/img/bg.jpg"
    gsettings set org.gnome.desktop.screensaver picture-uri "/usr/share/backgrounds/img/sbg.jpg"

    # GMD 登录背景图
#    sudo sed -i "/background: \#2c001e/c\  background: #2c001e url(file:///usr/share/backgrounds/img/gmd.png);" /usr/share/gnome-shell/theme/ubuntu.css
#    sudo sed -i '/background-repeat: repeat;/c\  background-repeat: no-repeat;\n  background-size: cover;\n  background-position: center; }' /usr/share/gnome-shell/theme/ubuntu.css
#    wget https://dl.opendesktop.org/api/files/download/id/1543091033/s/684c017b9bc8bde0b8b58f02beca18dc3b0face00448135253b3315f94a128fb2ccccdaa569bb6eaa075580074351ac6300af549a582b5514d86aa573f21036e/t/1565402816/lt/download/High_Ubunterra_2.3\(Pass\).tar.xz
    cd ./theme
    tar -xJf ./High_Ubunterra_2.3.tar.xz
    cd ./High_Ubunterra_2.3
    ./install.sh
    cd ../../
    sudo sed -i "/background: \#2c001e/c\  background: #2c001e url(file:///usr/share/backgrounds/img/gmd.png);" /usr/share/gnome-shell/theme/ubuntu.css

    # 设置为2个静态工作区
    gsettings set org.gnome.mutter dynamic-workspaces false
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 2

    gnome_shell_extension

    cat <<- EOF


################################################
##                                            ##
##          Theme Config Success!             ##
##                                            ##
################################################


EOF

sleep 1
}

_theme
