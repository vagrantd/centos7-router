#!/usr/bin/env bash
# https://www.zfl9.com/ss-redir.html#%E5%AE%89%E8%A3%85%E4%BE%9D%E8%B5%96

set -e
set -u

centos::chinadns() {
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
    # sudo mkdir -p /etc/chinadns/
    # sudo cp -af chnroute.txt /etc/chinadns/

    popd
}

centos::dnsforwarder() {
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
    export MBEDTLS_VER=2.9.0
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
    cp -af ss-tproxy /usr/local/bin/
    cp -af ss-switch /usr/local/bin/
    chown root:root /usr/local/bin/ss-tproxy /usr/local/bin/ss-switch
    chmod +x /usr/local/bin/ss-tproxy /usr/local/bin/ss-switch
    mkdir -m 0755 -p /etc/tproxy
    cp -af pdnsd.conf /etc/tproxy/
    cp -af chnroute.txt /etc/tproxy/
    cp -af chnroute.ipset /etc/tproxy/
    cp -af ss-tproxy.conf /etc/tproxy/
    chown -R root:root /etc/tproxy
    chmod 0644 /etc/tproxy/*

    cp -af ss-tproxy.service /etc/systemd/system/
    systemctl daemon-reload

    popd
}

cd /tmp

# 1. curl
yum install -y curl

# 2. ipset
centos::ipset

# 3. iproute2
yum install -y iproute

# 4. haveged
yum -y install haveged
systemctl enable haveged
systemctl start haveged

# 5. pdnsd
rpm -ivh http://members.home.nl/p.a.rombouts/pdnsd/releases/pdnsd-1.2.9a-par_sl6.x86_64.rpm

# 6. chinadns
centos::chinadns

centos::shadowsocks-libev

centos::ss-tproxy

# centos::dnsforwarder

cp /vagrant/ss-tproxy.conf /etc/tproxy/ss-tproxy.conf
