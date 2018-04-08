#!/usr/bin/env bash

set -e
set -u

install::chinadns() {
    sudo yum install -y wget

    ## 获取 chinadns 源码
    wget https://github.com/shadowsocks/ChinaDNS/releases/download/1.3.2/chinadns-1.3.2.tar.gz

    ## 解压 chinadns 源码
    tar xf chinadns-1.3.2.tar.gz

    ## 编译 chinadns
    pushd chinadns-1.3.2/
    ./configure
    make && sudo make install

    ## chinadns 相关文件
    sudo mkdir -p /etc/chinadns/
    sudo cp -af chnroute.txt /etc/chinadns/

    popd
}

install::dnsforwarder() {
    sudo yum install -y libcurl-devel wget unzip

    ## 获取 dnsforwarder 源码
    wget https://github.com/holmium/dnsforwarder/archive/6.zip
    unzip 6.zip

    ## 编译 dnsforwarder
    pushd dnsforwarder-6/
    ./configure
    make && sudo make install

    ## 初始化 dnsforwarder
    /usr/local/bin/dnsforwarder -p
    mkdir -p ~/.dnsforwarder
    cp -af default.config ~/.dnsforwarder/config

    popd
}

centos::chinadns() {
    install::chinadns
}

centos::dnsforwarder() {
    install::dnsforwarder
}

centos::ipset() {
    sudo yum install ipset -y
}

centos::shadowsocks-libev() {
    sudo yum install git gettext gcc autoconf libtool automake make asciidoc xmlto c-ares-devel libev-devel openssl-devel -y

    # 编译&安装 "Libsodium"
    export LIBSODIUM_VER=1.0.16
    wget https://github.com/jedisct1/libsodium/releases/download/$LIBSODIUM_VER/libsodium-$LIBSODIUM_VER.tar.gz
    tar xvf libsodium-$LIBSODIUM_VER.tar.gz
    pushd libsodium-$LIBSODIUM_VER
    ./configure --prefix=/usr && make
    sudo make install
    popd
    sudo ldconfig

    # 编译&安装 "MbedTLS"
    export MBEDTLS_VER=2.8.0
    wget https://tls.mbed.org/download/mbedtls-$MBEDTLS_VER-gpl.tgz
    tar xvf mbedtls-$MBEDTLS_VER-gpl.tgz
    pushd mbedtls-$MBEDTLS_VER
    make SHARED=1 CFLAGS=-fPIC
    sudo make DESTDIR=/usr install
    popd
    sudo ldconfig

    # 编译&安装 "shadowsocks-libev"
    git clone https://github.com/shadowsocks/shadowsocks-libev.git
    pushd shadowsocks-libev
    git submodule update --init --recursive
    ./autogen.sh && ./configure && make
    sudo make install

    popd
}

centos::ss-tproxy() {
    git clone https://github.com/zfl9/ss-tproxy.git
    pushd ss-tproxy/
    sudo cp -af ss-tproxy /usr/local/bin/
    sudo cp -af ss-tproxy.conf /etc/
    sudo cp -af ss-tproxy.service /etc/systemd/system/
    sudo systemctl daemon-reload
    popd
}


cd /tmp
centos::chinadns
centos::dnsforwarder
centos::ipset
centos::shadowsocks-libev
centos::ss-tproxy
