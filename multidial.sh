#!/bin/sh
DEV=$1
VLANID=$2
username=$3
password=$4
startnum=$5
stopnum=$6
MACADDR=40:00:02:$(openssl rand -hex 3 | sed 's/\(..\)/\1:/g; s/.$//')

ip link show ${DEV}.${VLANID}
if [ $? -eq 0 ]; then
    ip link set ${DEV}.${VLANID} up
else
    ip link set ${DEV} up
    ip link add link ${DEV} name ${DEV}.${VLANID} type vlan id ${VLANID}
    ip link set dev ${DEV}.${VLANID} address ${MACADDR}
    ip link set ${DEV}.${VLANID} up
fi

for i in `seq $startnum $stopnum`;do
ip link show macvlan$i
if [ $? -eq 0 ]; then
    ip link set macvlan$i up
else
    ip link add link ${DEV}.${VLANID} macvlan$i type macvlan
    ip link set macvlan$i up
fi
cat > /etc/ppp/peers/ppp${i} <<EOF
unit $i
+ipv6
nodefaultroute
usepeerdns
maxfail 1
user $username
password $password
mtu 1492
mru 1492
plugin rp-pppoe.so
nic-macvlan$i
EOF
done
