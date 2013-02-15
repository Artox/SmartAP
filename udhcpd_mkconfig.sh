#!/bin/sh

. ./shflags

DEFINE_string 'start' '192.168.0.2' 'First Ip Address to be served' 's'
DEFINE_string 'end' '192.168.0.254' 'Last IP to be served' 'e'
DEFINE_string 'netmask' '255.255.255.0' 'Subnet Mask' 'n'
DEFINE_string 'lease' '3600' 'Lease Time for IPs' 'l'
DEFINE_string 'router' '192.168.0.1' 'IP Address of the Router' 'r'
DEFINE_string 'nameserver1' '8.8.8.8' 'Primary Nameservers' 'a'
DEFINE_string 'nameserver2' '8.8.4.4' 'Secondary Nameserver' 'b'
DEFINE_string 'device' 'wlan0' 'Wireless LAN Device Name' 'd'
DEFINE_string 'pid' '/var/run/udhcpd.pid' 'PID File Path' 'p'
DEFINE_string 'config' 'udhcpd.conf' 'Output File Name' 'c'

FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

firstip=${FLAGS_start}
lastip=${FLAGS_end}
netmask=${FLAGS_netmask}
leasetime=${FLAGS_lease}
router=${FLAGS_router}
nameserver="${FLAGS_nameserver1} ${FLAGS_nameserver2}"
device=${FLAGS_device}
pidfile=${FLAGS_pid}
configfile="${FLAGS_config}"
echo "First IP: $firstip"
echo "Last IP: $lastip"
echo "Netmask: $netmask"
echo "Lease Time: $leasetime"
echo "Router: $router"
echo "Nameserver: $nameserver"
echo "Device: $device"

cat > "$configfile" << "EOF"
start AUTOREPLACE_FIRSTIP
end   AUTOREPLACE_LASTIP
interface AUTOREPLACE_DEVICE
pidfile AUTOREPLACE_PIDFILE
lease_file /var/lib/udhcpd/udhcpd.leases
remaining yes
option subnet AUTOREPLACE_SUBNET
option lease AUTOREPLACE_LEASETIME
option router AUTOREPLACE_ROUTER
option dns AUTOREPLACE_DNS
EOF
sed -e "s;AUTOREPLACE_FIRSTIP;$firstip;g" \
    -e "s;AUTOREPLACE_LASTIP;$lastip;g" \
    -e "s;AUTOREPLACE_SUBNET;$netmask;g" \
    -e "s;AUTOREPLACE_LEASETIME;$leasetime;g" \
    -e "s;AUTOREPLACE_ROUTER;$router;g" \
    -e "s;AUTOREPLACE_DNS;$nameserver;g" \
    -e "s;AUTOREPLACE_DEVICE;$device;g" \
    -e "s;AUTOREPLACE_PIDFILE;$pidfile;g" \
    -i "$configfile"

echo "Configuration written to $configfile"
