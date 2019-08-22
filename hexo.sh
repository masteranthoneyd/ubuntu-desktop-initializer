#!/bin/bash
set -e
source env.sh

function _nodejs_hexo() {
    mkdir -p ${APP_DIR}/nodejs
    NODEJS_VERSION=$(curl -sL https://nodejs.org/download/release/index.tab | awk '($10 != "-" && NR != 1) { print $1; exit}')
    NODEJS_NAME=node-${NODEJS_VERSION}-linux-x64
    pwget -L https://nodejs.org/download/release/${NODEJS_VERSION}/${NODEJS_NAME}.tar.xz -P ${APP_DIR}/nodejs
    tar -xJf ${APP_DIR}/nodejs/${NODEJS_NAME}.tar.xz -C ${APP_DIR}/nodejs
    sudo ln -s ${APP_DIR}/nodejs/${NODEJS_NAME}/bin/node /usr/local/bin/node
    sudo ln -s ${APP_DIR}/nodejs/${NODEJS_NAME}/bin/npm /usr/local/bin/npm
    sudo ln -s ${APP_DIR}/nodejs/${NODEJS_NAME}/bin/npx /usr/local/bin/npx
    npm config set registry https://registry.npm.taobao.org/
    npm install -g hexo-cli
    sudo ln -s ${APP_DIR}/nodejs/${NODEJS_NAME}/bin/hexo /usr/local/bin/hexo
    cat <<- EOF


################################################
##                                            ##
##          Nodejs Install Success!           ##
##                                            ##
################################################

EOF
    echo "Nodejs version: $(node -v)"
    sleep 1
}

function _go_minify() {
    mkdir -p \$GOPATH/src/golang.org/x/
    cd \$GOPATH/src/golang.org/x/
    proxychains4 git clone https://github.com/golang/net.git
    proxychains4 git clone https://github.com/golang/sys.git
    proxychains4 git clone https://github.com/golang/tools.git
    proxychains4 go get github.com/tdewolff/minify/cmd/minify

    cat <<- EOF


################################################
##                                            ##
##          Minify Install Success!           ##
##                                            ##
################################################

EOF
    sleep 1
}

_nodejs_hexo
_go_minify
