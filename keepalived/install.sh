#!/bin/bash

source ./kl_install.sh


{
    cat kl_global.conf
    complete_ins1
    echo ""
    complete_ins2
} > /tmp/keepalived.conf
mv /tmp/keepalived.conf /etc/keepalived/
systemctl restart snap.keepalived.daemon


setup_ipt() {
    iface1=ens3
    vip1=172.16.70.200

    local iface1=$1
    local vip1=$2
    local mark=$3
    local chainName=LOADBALANCER-$iface1
    ip addr add $vip1/32 dev lo 2>/dev/null
    if ! iptables -t mangle -L -n | grep -q "$chainName";then
        iptables -t mangle -N "$chainName"
        iptables -t mangle -A PREROUTING -j "$chainName"
    fi
    iptables -t mangle -F $chainName
    iptables -t mangle -A $chainName -d $vip1/32 -i $iface1 -p ip -j MARK --set-xmark $mark/$mark

    shift
    shift
    shift
    for mac in "$@"
    do
        iptables -t mangle -A $chainName -d $vip1/32 -i $iface1 -p ip -m mac --mac-source $mac -j MARK --set-xmark 0x0/$mark
    done

}

setup_ipt ens3 172.16.70.200 0x1 0c:da:00:98:39:84 0c:da:00:e5:0a:e9 0c:da:00:ed:8a:e0
setup_ipt ens4 172.23.1.200  0x2 0c:da:00:22:57:a8 0c:54:00:f6:8f:37 0c:da:00:c8:8f:78
