#!/bin/sh

LAN_NIC=eth1
WAN_NIC=eth0

service iptables stop
iptables -F                 !** IPテーブルの設定をクリア。

iptables -P INPUT DROP      !** ルータ自体に入ってきたパケットは捨てる。
iptables -P OUTPUT ACCEPT   !** ルータから出てきたパケットは素通り
iptables -P FORWARD ACCEPT  !** ルータから通り抜けようとするパケットは通す。

LAN_NETMASK=`ifconfig $LAN_NIC | sed -e 's/^.*Mask:\([^ ]*\)$/\1/p' -e d`
LAN_NETADDR=`netstat -rn | grep $LAN_NIC | grep $LAN_NETMASK | awk '{print $1}'`

iptables -t nat -A POSTROUTING -o $WAN_NIC -s $LAN_NETADDR/$LAN_NETMASK -j MASQUERADE

iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -s 127.0.0.0/8 -j ACCEPT

iptables -A INPUT -i $LAN_NIC -j ACCEPT

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A OUTPUT -o $WAN_NIC -d 127.0.0.0/8 -j DROP
iptables -A OUTPUT -o $WAN_NIC -d 10.0.0.0/8 -j DROP
iptables -A OUTPUT -o $WAN_NIC -d 172.16.0.0/12 -j DROP
iptables -A OUTPUT -o $WAN_NIC -d 192.168.0.0/16 -j DROP

#service iptables save
#service iptables start
