#!/bin/sh

. ./shflags

DEFINE_string 'device' 'wlan0' 'Wireless LAN Device Name' 'd'
DEFINE_string 'ssid' 'SmartAP' 'SSID to use for the Access Point' 's'
DEFINE_string 'password' 'SuperSecret' 'Password to use for the Access Point' 'p'
# DEFINE_string 'firstip' '192.168.0.1' 'First IP Address in the Network for Clients' 'f'
# DEFINE_string 'lastip' '192.168.0.254' 'Last IP Address in the Network for Clients' 'l'
# DEFINE_string 'netmask' '255.255.255.0' 'Subnet Mask for the Client network' 'n'
DEFINE_string 'nameserver' '8.8.8.8 8.8.4.4' 'space-seperated list of up to 2 nameservers for the Clients' 'b'

FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

device=${FLAGS_device}
ssid=${FLAGS_ssid}
password=${FLAGS_password}
nameserver="${FLAGS_nameserver}"
hostip=192.168.1.1
firstip=192.168.1.2
lastip=192.168.1.254
netmask=255.255.255.0

# work dir
workdir=`pwd`

# create hostapd config file
./hostapd_mkconfig.sh \
--device=$device \
--ssid=$ssid \
--password=$password \
--config=$workdir/hostapd.conf

# create udhcpd config file
./udhcpd_mkconfig.sh \
--device=$device \
--start=$firstip \
--end=$lastip \
--netmask=$netmask \
--router=$hostip \
--nameserver=$nameserver \
--pid=$workdir/udhcpd.pid \
--config=$workdir/udhcpd.conf

# set up network interface
# possible alternative might be to flush leases file
# and run udhcpc to get an IP directly form udhcpd
ifconfig $device up $hostip netmask $netmask
sleep 1

# start udhcpd and hostapd in background
./udhcpd_run.sh $workdir/udhcpd.pid $workdir/udhcpd.conf &
pid_dhcpd=$!
./hostapd_run.sh -P $workdir/hostapd.pid $workdir/hostapd.conf &
pid_hostapd=$!

# helper function to stop udhcpd and hostapd
shutdownap() {
kill -s TERM $pid_dhcpd 2>/dev/null
kill -s TERM $pid_hostapd 2>/dev/null
echo "Terminated Daemons"
}

# catch SIGTERM,SIGINT and forward them to the running daemons
trap shutdownap INT TERM

# wait for hostapdand udhcpd to terminate
# possibly bad idea, what if one of them dies?
wait

# deactivate interface
ifconfig $device down

echo "Done"
