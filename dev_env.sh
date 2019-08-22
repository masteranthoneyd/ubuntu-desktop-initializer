#!/bin/bash
set -e
source env.sh

function _jdk() {
    JDK_TAR=jdk-8u211-linux-x64.tar.gz
    JDK_DIR=jdk1.8.0_211
#    proxychains4 curl -L -b "oraclelicense=a" -O https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/${JDK_TAR}
    wget https://cdn.yangbingdong.com/resource/java/jdk-8u211-linux-x64.tar.gz
    sleep 1
    sudo mv ${JDK_TAR} /usr/local/${JDK_TAR}
    if ! [[ -f /usr/local/${JDK_TAR} ]]; then
        echo "Download JDK fail"
        exit 1
    fi
    sudo tar -zxf /usr/local/${JDK_TAR} -C /usr/local/
    sudo rm /usr/local/${JDK_TAR}
    sudo ln -s /usr/local/${JDK_DIR} /usr/local/jdk
    sudo tee /etc/profile.d/jdk.sh <<- EOF
export JAVA_HOME=/usr/local/jdk
export PATH=\$JAVA_HOME/bin:\$PATH
EOF
    sudo update-alternatives --install "/usr/bin/java" "java" "/usr/local/jdk/bin/java" 1500
    sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/local/jdk/bin/javac" 1500
    sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/local/jdk/bin/javaws" 1500

    tee -a ${HOME_DIR}/.oh-my-zsh/themes/bullet-train.zsh-theme <<- EOF
# Java
prompt_java() {
  local java_prompt
  if type java >/dev/null 2>&1; then
    java_prompt=\$(java -version 2>&1 | head -n 1 | awk -F '"' '{print \$2}')
  else
    return
  fi
  java_prompt=\${java_prompt}
  prompt_segment \$BULLETTRAIN_NVM_BG \$BULLETTRAIN_NVM_FG "\U2615 "\$java_prompt
}
EOF
    sed -i '0,/nvm/s//java/' ${HOME_DIR}/.oh-my-zsh/themes/bullet-train.zsh-theme

    cat <<- EOF


################################################
##                                            ##
##           Java Install Success!            ##
##                                            ##
################################################

EOF
    java -version
    sleep 1
}

function _scala() {
    SCALA_VERSION=2.13.0
    pwget https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz
    sudo mv scala-${SCALA_VERSION}.tgz /usr/local/scala-${SCALA_VERSION}.tgz
    sudo tar -zxf /usr/local/scala-${SCALA_VERSION}.tgz -C  /usr/local/
    sudo rm /usr/local/scala-${SCALA_VERSION}.tgz
    sudo ln -s /usr/local/scala-${SCALA_VERSION} /usr/local/scala
    sudo tee /etc/profile.d/scala.sh <<- EOF
export SCALA_HOME=/usr/local/scala
export PATH=\$PATH:\$SCALA_HOME/bin
EOF
    cat <<- EOF


################################################
##                                            ##
##          Scala Install Success!            ##
##                                            ##
################################################

EOF
    source /etc/profile.d/scala.sh
    scala -version
    sleep 1
}

function _go() {
    papti golang
    sudo tee /etc/profile.d/go.sh <<- EOF
export GOPATH=${HOME}/go
export PATH=\$GOPATH/bin:\$PATH
EOF
        cat <<- EOF


################################################
##                                            ##
##         Golang Install Success!            ##
##                                            ##
################################################

EOF
    sleep 1
}

function _download_tomcat() {
    mkdir -p ${APP_DIR}/tomcat
#    pwget -P ${APP_DIR}/tomcat https://www-eu.apache.org/dist/tomcat/tomcat-8/v8.5.42/bin/apache-tomcat-8.5.42.tar.gz
    wget -P ${APP_DIR}/tomcat http://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-8/v8.5.42/bin/apache-tomcat-8.5.42.tar.gz
    tar -zxf ${APP_DIR}/tomcat/*.tar.gz -C ${APP_DIR}/tomcat
    cat <<- EOF


################################################
##                                            ##
##             Tomcat Downloaded!             ##
##                                            ##
################################################

EOF
    sleep 1
}

function _download_maven() {
    mkdir -p ${APP_DIR}/maven
    mkdir -p ${APP_DIR}/maven/maven-repo
#    pwget -P ${APP_DIR}/maven http://ftp.jaist.ac.jp/pub/apache/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz
    wget -P ${APP_DIR}/maven http://mirror.bit.edu.cn/apache/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz
    tar -zxf ${APP_DIR}/maven/*.tar.gz -C ${APP_DIR}/maven
    sudo tee /etc/profile.d/maven.sh <<- EOF
export M2_HOME=//home/ybd/data/application/maven/apache-maven-3.6.0
export PATH=\${M2_HOME}/bin:\$PATH
EOF
    cat <<- EOF


################################################
##                                            ##
##              Maven Downloaded!             ##
##                                            ##
################################################

EOF
    sleep 1
}

function _create_network() {
    sudo docker network create --attachable backend
}

function _portainer() {
    sudo docker-compose -f ${DOCKER_DIR}/portainer/docker-compose.yml up -d
}

function _logrotate() {
    sudo docker-compose -f ${DOCKER_DIR}/logrotate/docker-compose.yml up -d
}

function _mysql() {
    papti mysql-client mycli
    chmod 644 ${DOCKER_DIR}/mysql/conf/config-file.cnf
    sudo docker-compose -f ${DOCKER_DIR}/mysql/docker-compose.yml up -d
    cat <<- EOF


################################################
##                                            ##
##                  Mysql Up!                 ##
##                                            ##
################################################

EOF
    sleep 1
}

function navicat_native() {
    mkdir -p ${APP_DIR}/navicat/navicat-keygen-for-x64
    wget http://download.navicat.com.cn/download/navicat121_premium_cs_x64.tar.gz -P ${APP_DIR}/navicat
    tar -zxf ${APP_DIR}/navicat/navicat121_premium_cs_x64.tar.gz -C ${APP_DIR}/navicat

    NAVICAT_CRACK_URL=""
    NAVICAT_CRACK_NAME=""
    for row in $(wget -qO - https://api.github.com/repos/DoubleLabyrinth/navicat-keygen/releases/latest | jq -c -r '.assets[]'); do
        NAVICAT_CRACK_NAME=`echo ${row} | jq -r '.name'`
        if [[ ${NAVICAT_CRACK_NAME} =~ "x64.zip" ]]; then
            NAVICAT_CRACK_URL=`echo ${row} | jq -r '.browser_download_url'`
            echo "Docker Compose release url is ${NAVICAT_CRACK_URL}"
            break
        fi
    done
   pwget ${NAVICAT_CRACK_URL} -P ${APP_DIR}/navicat
   unzip -d ${APP_DIR}/navicat/navicat-keygen-for-x64 ${APP_DIR}/navicat/${NAVICAT_CRACK_NAME}
}

function navicat_with_crack() {
    if [[ ${NAVICAT_CRACK_RESOURCE} == "cdn" ]]; then
        wget https://cdn.yangbingdong.com/resource/navicat/navicat64.tar.xz
        wget https://cdn.yangbingdong.com/resource/navicat/navicat121_premium_cs_x64.tar.xz
    elif [[ ${NAVICAT_CRACK_RESOURCE} == "smb" ]]; then
        papti smbclient
        smbget -U share%share smb://192.168.0.200/share/deptdev/software/ubuntu/archive/navicat/navicat64.tar.xz
        smbget -U share%share smb://192.168.0.200/share/deptdev/software/ubuntu/archive/navicat/navicat121_premium_cs_x64.tar.xz
    else
        echo "Error navicat crack resource"
        exit 1
    fi
    tar -xJf navicat64.tar.xz -C ${HOME_DIR}
    tar -xJf navicat121_premium_cs_x64.tar.xz -C ${APP_DIR}/navicat
    rm navicat64.tar.xz navicat121_premium_cs_x64.tar.xz
}

function _navicat() {
    sudo apt update
    papti wine-stable
    mkdir -p ${APP_DIR}/navicat
    case ${NAVICAT} in
     crack)
        navicat_with_crack
        ;;
     *)
        navicat_native
        ;;
    esac
    echo 'alias navicat="nohup '${APP_DIR}'/navicat/navicat121_premium_cs_x64/start_navicat > /dev/null 2>&1 &"' >> ${HOME_DIR}/.zshrc
    cat <<- EOF


################################################
##                                            ##
##        Navicat Install Success!            ##
##                                            ##
################################################

EOF
    sleep 1
}

function _redis() {
    papti redis-tools
    sudo snap install redis-desktop-manager
    sudo docker-compose -f ${DOCKER_DIR}/redis/docker-compose.yml up -d
    cat <<- EOF


################################################
##                                            ##
##                  Redis Up!                 ##
##                                            ##
################################################

EOF
    sleep 1
}

function _kafka() {
    if [[ ${UP_KAFKA} == "true" ]]; then
        sudo docker-compose -f ${DOCKER_DIR}/kafka/docker-compose.yml up -d
        cat <<- EOF


################################################
##                                            ##
##           Kafka & Zookeeper Up!            ##
##                                            ##
################################################

EOF
        sleep 1
    fi

}

function _rabbitmq() {
    if [[ ${UP_RABBITMQ} == "true" ]]; then
        sudo docker-compose -f ${DOCKER_DIR}/rabbitmq/docker-compose.yml up -d
        cat <<- EOF


################################################
##                                            ##
##                RabbitMQ Up!                ##
##                                            ##
################################################

EOF
    sleep 1
    fi
}

function _download_jetbrains_toolbox() {
    papti jq
    TOOLBOX_URL=`curl 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release&build=' | jq -r '.TBA[0].downloads.linux.link'`
    mkdir -p ${APP_DIR}/jetbrains
    pwget -P ${APP_DIR}/jetbrains ${TOOLBOX_URL}
    tar -zxvf ${APP_DIR}/jetbrains/jetbrains* -C ${APP_DIR}/jetbrains/ --strip-components 1
    rm -rf ${APP_DIR}/jetbrains/*.tar.gz
    wget -P ${APP_DIR}/jetbrains https://cdn.yangbingdong.com/resource/java/jetbrains-agent.zip
    wget -P ${APP_DIR}/jetbrains https://cdn.yangbingdong.com/resource/java/settings.jar
    cat <<- EOF


################################################
##                                            ##
##        JetBrains Toolbox Downloaded!       ##
##                                            ##
################################################

EOF
    sleep 1
}

function _download_postman() {
    papti libgconf-2-4
    mkdir -p ${APP_DIR}/postman
    wget -L https://dl.pstmn.io/download/latest/linux64 -O Postman.tar.gz
    tar -zxf Postman.tar.gz -C ${APP_DIR}/postman --strip-components 1
    rm Postman.tar.gz
    tee ${HOME_DIR}/.local/share/applications/postman.desktop <<- EOF
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Postman
Exec=${APP_DIR}/postman/Postman
Icon=${APP_DIR}/postman/app/resources/app/assets/icon.png
Categories=Development;

Name[zh_CN]=postman.desktop
EOF
}

function _fix_idea_conflict() {
    gsettings set org.gnome.desktop.wm.keybindings toggle-shaded "[]"
    gsettings set org.gnome.settings-daemon.plugins.media-keys screencast "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "[]"
    gsettings set org.gnome.desktop.wm.keybindings begin-move "[]"
}


_jdk
_scala
_go
#_download_tomcat
_download_maven
_create_network
_portainer
_logrotate
_mysql
_navicat
_redis
_kafka
_rabbitmq
_download_jetbrains_toolbox
_download_postman
_fix_idea_conflict
