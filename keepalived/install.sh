#!/bin/bash

iface1=ens3
myip1=$(ip -4 -o addr show $iface1| grep -m 1 -o 'inet [0-9.]*' | awk '{print $2}')

vip1=172.16.70.200
pip1=172.16.70.51
pip2=172.16.70.52
pip3=172.16.70.53

if [ "$pip1" = "$myip1" ];then
    pip1=
elif [ "$pip2" = "$myip1" ];then
    pip2=
elif [ "$pip3" = "$myip1" ];then
    pip3=
fi

sed  \
    -e "s/@IFACE1@/$iface1/g" \
    -e "s/@MYIP1@/$myip1/g" \
    -e "s/@VIP1@/$vip1/g" \
    -e "s/@PEERIP1@/$pip1/g" \
    -e "s/@PEERIP2@/$pip2/g" \
    -e "s/@PEERIP3@/$pip3/g" \
    keepalived.conf > /tmp/keepalived.conf
mv /tmp/keepalived.conf /etc/keepalived/
systemctl restart snap.keepalived.daemon


setup_ipt() {
iface1=ens3
vip1=172.16.70.200
ip addr add $vip1/32 dev lo 2>/dev/null
if ! iptables -t mangle -L -n | grep LOADBALANCER;then
    iptables -t mangle -N LOADBALANCER-IPVS-DR
    iptables -t mangle -A PREROUTING -j LOADBALANCER-IPVS-DR
fi
iptables -t mangle -F LOADBALANCER-IPVS-DR
iptables -t mangle -A LOADBALANCER-IPVS-DR -d $vip1/32 -i $iface1 -p ip -j MARK --set-xmark 0x1/0x1

iptables -t mangle -A LOADBALANCER-IPVS-DR -d $vip1/32 -i $iface1 -p ip -m mac --mac-source 0c:da:00:98:39:84 -j MARK --set-xmark 0x0/0x1
iptables -t mangle -A LOADBALANCER-IPVS-DR -d $vip1/32 -i $iface1 -p ip -m mac --mac-source 0c:da:00:e5:0a:e9 -j MARK --set-xmark 0x0/0x1
iptables -t mangle -A LOADBALANCER-IPVS-DR -d $vip1/32 -i $iface1 -p ip -m mac --mac-source 0c:da:00:ed:8a:e0 -j MARK --set-xmark 0x0/0x1
}

setup_ipt
