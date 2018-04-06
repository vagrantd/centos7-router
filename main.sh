#!/usr/bin/env bash
VM=build_centos7_router
BOX="lot/centos7-router"

CMD=$1
case "$CMD" in
    package)
        rm ./package.box
        vagrant box remove "$BOX"

        vagrant destroy
        vagrant up

        vagrant package --base "$VM"
        vagrant box add "$BOX" ./package.box
        ;;

    *)
        echo "Usage: ./main.sh package"
        ;;
esac
