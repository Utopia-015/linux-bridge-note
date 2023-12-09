#!/bin/bash

a_ppps=$(ls -l /sys/class/net/ | grep ppp | awk '{print $9}')

all_ppps=$(ls -l /etc/ppp/peers/ | grep ppp | awk '{print $9}')

[ -z "$all_ppps" ] && echo "No peer configuration file found. Exiting..." && exit 0

for i in $all_ppps; do
    flag=1
    while [ $flag -eq 1 ]; do
        if [[ ${a_ppps} =~ "${i}" ]]; then
            flag=0
            echo "$i dailed successfully."
            tabid="1${i//ppp/}"
            ipaddr=$(ip a show ${i} | sed -nE '/inet[^6]/p' | awk '{print $2}')
            ip rule | grep ${ipaddr} > /dev/null
            [ $? -eq 0 ] &&
                echo "ip rule already added." ||
                ip rule add from ${ipaddr} table ${tabid}
            ip route | grep default | grep $i > /dev/null
            [ $? -eq 0 ] &&
                echo "default route already added." ||
                ip route add default dev $i metric ${tabid}
            [ -n "$(ip route show table ${tabid})" ] &&
                echo "route table already added." ||
                ip route add default dev $i table ${tabid}
        else
            echo "$i does not exist. Redial now..."
            /usr/sbin/pppd call $i
            sleep 5
            a_ppps=$(ls -l /sys/class/net/ | grep ppp | awk '{print $9}')
        fi
    done
done
