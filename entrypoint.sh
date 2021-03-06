#!/bin/sh

set -e

# start logging
service rsyslog start

sed -i "s/RADIUS_ADDR RADIUS_SECRET/$RADIUS_ADDR $RADIUS_SECRET/g" /etc/radiusclient/servers
sed -i "s/RADIUS_ADDR:RADIUS_AUTH_PORT/$RADIUS_ADDR:$RADIUS_AUTH_PORT/g" /etc/radiusclient/radiusclient.conf
sed -i "s/RADIUS_ADDR:RADIUS_ACCT_PORT/$RADIUS_ADDR:$RADIUS_ACCT_PORT/g" /etc/radiusclient/radiusclient.conf
echo "" > /etc/radiusclient/port-id-map

# enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

# configure firewall

local_ip = "`ifconfig eth0 | grep "inet addr" | awk '{print $2}' |tr -d "addr:"`"

iptables -t nat -A POSTROUTING -s 10.79.97.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.79.97.0/24 -o eth0 -j SNAT --to-source ${local_ip}
iptables -A FORWARD -s 10.79.97.0/24 -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j TCPMSS --set-mss 1356


exec "$@"
