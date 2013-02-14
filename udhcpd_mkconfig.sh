#!/bin/sh

source ./shflags

DEFINE_string 'start' '192.168.0.2' 'First Ip Address to be served' 's'
DEFINE_string 'end' '192.168.0.254' 'Last IP to be served' 'e'
DEFINE_string 'netmask' '255.255.255.0' 'Subnet Mask' 'n'
DEFINE_string 'lease' '3600' 'Lease Time for IPs' 'l'
DEFINE_string 'device' 'wlan0' 'Wireless LAN Device Name' 'd'

FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

echo "First IP: ${FLAGS_start}"
echo "Last IP: ${FLAGS_end}"
echo "Netmask: ${FLAGS_netmask}"
echo "Lease Time: ${FLAGS_lease}"
echo "Device: ${FLAGS_device}"
firstip=${FLAGS_start}
lastip=${FLAGS_end}
netmask=${FLAGS_netmask}
leasetime=${FLAGS_lease}
device=${FLAGS_device}

cat > udhcpd.conf << "EOF"
start AUTOREPLACE_FISTIP
end   AUTOREPLACE_LASTIP
interface AUTOREPLACE_DEVICE

lease_file /var/lib/udhcpd/udhcpd.leases
remaining yes
option subnet AUTOREPLACE_SUBNET
option lease AUTOREPLACE_LEASETIME
EOF
sed -e "s;AUTOREPLACE_FIRSTIP;$firstip;g" \
    -e "s;AUTOREPLACE_LASTIP;$lastip;g" \
    -e "s;AUTOREPLACE_SUBNET;$netmask;g" \
    -e "s;AUTOREPLACE_LEASETIME;$leasetime;g" \
    -e "s;AUTOREPLACE_DEVICE;$device;g" \
    -i udhcpd.conf

echo "Finished Generating udhcpd.conf"
