#!/bin/bash

a_ppps=$(ls -l /sys/class/net/ | grep ppp | awk '{print $9}')

all_ppps=$(ls -l /etc/ppp/peers/ | grep ppp | awk '{print $9}')

[ -z "$all_ppps" ] && echo "No peer configuration file found. Exiting..." && exit 0

for i in $all_ppps; do
    flag=1
    while [ $flag -eq 1 ]; do
        if [[ ${a_ppps} =~ "${i}" ]]; then
            echo "${i}: Connection created."
            ipaddr=$(ip a show ${i} | sed -nE '/inet[^6]/p' | awk '{print $2}')
            [ -z "$ipaddr" ] && {
                echo "Waiting for network..."
                sleep 3 
                continue 
                } || flag=0
            tabid="1${i//ppp/}"
            ip rule | grep ${ipaddr} > /dev/null &&
                echo "Route rule already added." || {
                echo "Adding route rule..."
                ip rule add from ${ipaddr} table ${tabid}
                }
            ip route | grep default | grep $i > /dev/null &&
                echo "Default route already added." || {
                echo "Adding default route..."
                ip route add default dev $i metric ${tabid}
                }
            [ -n "$(ip route show table ${tabid})" ] &&
                echo "Route table already added." || {
                echo "Adding route table..."
                ip route add default dev $i table ${tabid}
                }
        else
            echo "${i}: Connection not exist. Redial now..."
            /usr/sbin/pppd call $i
            sleep 3
            a_ppps=$(ls -l /sys/class/net/ | grep ppp | awk '{print $9}')
        fi
    done
done
