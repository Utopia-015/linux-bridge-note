#!/bin/bash
IPCIDR=$1
GATEWAY=$2
VLANID=$3
MACADDR=40:00:02:$(openssl rand -hex 3 | sed 's/\(..\)/\1:/g; s/.$//')
IPADDR=$(echo ${IPCIDR}|sed 's/\/[0-9]\{1,2\}//')

ip link add link enp7s0f1 name enp7s0f1.${VLANID} type vlan id ${VLANID}
ip link set dev enp7s0f1.${VLANID} address ${MACADDR}
ip link set enp7s0f1.${VLANID} up
ip addr add dev enp7s0f1.${VLANID} ${IPCIDR} brd +
ip rule add from ${IPADDR} table ${VLANID}
ip route add default via ${GATEWAY} dev enp7s0f1.${VLANID} table ${VLANID}
