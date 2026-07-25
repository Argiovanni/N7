#!/bin/bash

set -e

echo "[INIT] Configuration CAN"

ip link set dev can0 down
ip link set dev can0 type can bitrate 250000 loopback off
ip link set dev can0 up

echo "[INIT] Configuration IP"
ip addr flush dev wlan0
ip addr add 192.168.1.1/24 dev wlan0
ip link set dev wlan0 up

echo "[INIT] Starting hotspot"
/usr/sbin/hostapd /etc/hostapd/hostapd.conf &

echo "[INIT] Attente réseau"
sleep 5

echo "[INIT] Starting Dino flask app"
exec /home/dino/Dino/.env/bin/python /home/dino/Dino/run.py
