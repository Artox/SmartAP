#!/bin/sh

#######################################################################
# USAGE: ./udhcpd_mkconfig.sh [flags] args
# flags:
#   -s,--start:  First Ip Address to be served (default: '192.168.0.2')
#   -e,--end:  Last IP to be served (default: '192.168.0.254')
#   -n,--netmask:  Subnet Mask (default: '255.255.255.0')
#   -l,--lease:  Lease Time for IPs (default: '3600')
#   -d,--device:  Wireless LAN Device Name (default: 'wlan0')
#   -c,--config:  Output File Name (default: 'udhcpd.conf')
#   -h,--[no]help:  show this help (default: false)
#######################################################################

source ./shflags

DEFINE_string 'start' '192.168.0.2' 'First Ip Address to be served' 's'
DEFINE_string 'end' '192.168.0.254' 'Last IP to be served' 'e'
DEFINE_string 'netmask' '255.255.255.0' 'Subnet Mask' 'n'
DEFINE_string 'lease' '3600' 'Lease Time for IPs' 'l'
DEFINE_string 'device' 'wlan0' 'Wireless LAN Device Name' 'd'
DEFINE_string 'config' 'udhcpd.conf' 'Output File Name' 'c'

FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

firstip=${FLAGS_start}
lastip=${FLAGS_end}
netmask=${FLAGS_netmask}
leasetime=${FLAGS_lease}
device=${FLAGS_device}
configfile="${FLAGS_config}"
echo "First IP: $firstip"
echo "Last IP: $lastip"
echo "Netmask: $netmask"
echo "Lease Time: $leasetime"
echo "Device: $device"

cat > "$configfile" << "EOF"
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
    -i "$configfile"

echo "Configuration written to $configfile"
