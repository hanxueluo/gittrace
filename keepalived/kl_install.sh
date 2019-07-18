#!/bin/bash

complete_kl_conf() {
    local iface1=$1
    local myip1=$(ip -4 -o addr show $iface1| grep -m 1 -o 'inet [0-9.]*' | awk '{print $2}')

    local vip1=$2
    local pip1=$3
    local pip2=$4
    local pip3=$5
    cat kl_ins.conf | \
    sed  \
        -e "s/@IFACE1@/$iface1/g" \
        -e "s/@MYIP1@/$myip1/g" \
        -e "s/@VIP1@/$vip1/g" \
        -e "s/@PEERIP1@/$pip1/g" \
        -e "s/@PEERIP2@/$pip2/g" \
        -e "s/@PEERIP3@/$pip3/g" \
       -e "/#UP#$myip1/d" -e "s/#UP#//g"
}

complete_ins1() {
    complete_kl_conf ens3 172.16.70.200 172.16.70.51 172.16.70.52 172.16.70.53 | \
        sed 's/@SERVER@/fwmark 1/g'
}

complete_ins2() {
    complete_kl_conf ens4 172.23.1.200 172.23.1.51 172.23.1.52 172.23.1.53 | \
        sed -e 's/@SERVER@/172.23.1.200 0/g' -e 's/lb_kind DR/lb_kind NAT/g'
}

#cat kl_global.conf
#complete_ins1
#echo ""
#complete_ins2
