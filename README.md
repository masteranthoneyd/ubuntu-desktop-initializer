# Ubuntu Desktop Initial Script

作为经常重装 Ubuntu 的人, 重装完后基本上都需要做一些系统调整, 主题配置, 软件安装, 开发环境安装等繁琐的事, 极度耗时. 于是这个脚本诞生了, 根据 ***[Ubuntu主题美化与常用软件记录](https://yangbingdong.com/2017/ubuntu-todo-after-install/)*** 编写的自动化脚本, 从而简化大部分的安装.

条件: **需要有效的 Shadowsocks 服务器** 

脚本在 Ubuntu18.04 已测试通过, 有时候出问题主要是在网络方面, 网络不同, 网络慢等.

毕竟我也只是个shell菜鸡, 写的不好请勿吐槽 =.=

## 使用方法

修改 `env.sh`

```
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
```

更多配置请查看 `env.sh`

# 涵盖内容

## 系统设置

- [x] 修改root密码
- [x] 修改默认编辑器为vim（默认为nano）
- [x] sudo 免密码
- [x] 关闭自动锁屏
- [x] windows双系统同一时间

## 系统软件

- [x] Docker
- [x] Docker Compose, 命令补全
- [x] Shadowsocks Client(Docker), 开启TCP Fast Open
- [x] privoxy, 已配置监听 0.0.0.0:8118
- [x] proxychains4, 已配置socks5 127.0.0.1:1080 监听
- [x] apt upgrade(升级)
- [x] ssh
- [x] curl
- [x] git, 配置全局 user.name, user.email
- [x] net-tools
- [x] gdebi
- [x] exfat驱动
- [x] screenfetch
- [x] snap, 已配置代理
- [x] zsh
- [x] oh-my-zsh, zsh-syntax-highlighting插件, 导入自定义样式
- [x] fast-apt, 终端自动补全


## 系统美化

- [x] 配置 oh-my-zsh 主题: robbyrussell
- [x] gnome-tweak-tool
- [x] dconf-editor
- [x] gnome-shell-extensions 
- [x] chrome-gnome-shell
- [x] 主题: Sweet
- [x] 图标: Suru Plus Icon, 已将文件夹图标颜色更换成cyan
- [x] 光标: Capitaine Cursors
- [x] Shell Theme: Sweet
- [x] 自定义背景图, 锁屏图
- [x] 自定义 GMD 登录背景

**Gnome Shell Extension**:

- [x] user-theme
- [x] places-menu
- [x] drive-menu
- [x] openweather, 已导入自定义配置
- [x] dash-to-dock, 已导入自定义配置
- [x] TopIcons Plus, 已导入自定义配置
- [x] Internet speed meter
- [x] DynamicTopBar, 已导入自定义配置
- [x] system-monitor

**Grub 2**

- [x] Grub Customizer
- [x] grub-theme-vimix
- [x] Grub time out modify to 10s

重启 Gnome Shell: `Alt` + `F2` -> `r` -> `Enter` 

## 常用软件

- [x] GenPAC全局代理(顺带安装了Pip3)
- [x] Chrome 浏览器
- [x] Typora MD编辑器
- [x] GIF制作软件 Peek
- [x] WPS
- [x] 备份工具 Timeshift
- [x] 钉钉 Dingtalk
- [x] Edex-ui
- [x] cmatrix 高逼格屏保
- [x] Shutter 截图软件, 并修复不能编辑问题, 设置快捷键 `Ctrl+Shift+Alt+A`
- [x] KVM
- [x] fcitx, 搜狗输入法, 已导入自定义配置(只要排除一些快捷键冲突)
- [x] SecureCRT 安装, License 在 `~/data/application/scrt` 中
- [x] Aria2 + AriaNg Web UI (Docker), 下载BaiduExporter
- [x] Deepin Wine, 微信以及企业微信
- [x] 收藏夹已添加:
    * Chrome
    * Firefox
    * Timeshift
    * DingTalk
    * Tweak Tool
    * WPS
    * Typora
    * TeamViewer
    * 系统监视器
    * Edex-Ui
    * IDEA
    * KVM
    * RedisDesktopManager
    * Postman
    * SecureCRT


## 开发环境

- [x] JDK, 版本信息嵌入到终端展示
- [x] Scala
- [x] Golang
- [x] JetBrains ToolBox 下载
- [x] 修复部分IDEA快捷键冲突
- [x] Maven 下载
- [x] Postman, 添加 desktop 图标

- [x] Portainer(Docker), [*127.0.0.1:9000*](127.0.0.1:9000), 账号: admin, 密码: 12345678
- [x] Logrotate(Docker)
- [x] MySQL(Docker)
- [x] MySQL终端客户端: mysql client, 智能终端客户端: mycli
- [x] 下载 Navicat For Linux, Navicat Key Gen (提供已破解版本, 仅限内部使用), 添加终端别名 'navicat'
- [x] Redis(Docker)
- [x] Redis 终端客户端: redis-tools, GUI 客户端: RedisDesktopManager
- [x] RabbitMQ With GUI(Docker)
- [x] Kafka(Docker) & Zookeeper(Docker)

- [x] Node.js, 动态获取最新 TLS 版本, 设置淘宝镜像
- [x] Hexo, minify压缩工具

# 手动处理

## Common

* 登录 Chrome 同步数据
* Chrome extension BaiduExporter
* 打开 SecureCRT 并填入 License 信息 (`~/data/application/scrt/license.txt`)

Option:

* Edex-UI
* Navicat crack (如果使用原生版本需要手动破解)

## Dev

* 打开 JetBrains ToolBox 并下载 IDEA
* 配置 Maven setting
* 下载 *[Tomcat8](https://tomcat.apache.org/download-80.cgi)* (Tomcat的小版本不固定, 经常导致404)

## Gnome extensions

*[Nvidia GPU Temperature Indicator](https://extensions.gnome.org/extension/541/nvidia-gpu-temperature-indicator/)* (Option)

## Other

* 利用 Timeshift 备份系统