#!/bin/sh

###################################
#
# For now this generates a config file for hostapd
# Encryption is WPA2 with preshared Key
# Arguments taken:
# -s <ssid>
# -p <preshared key>
#
###################################

source ./shflags

DEFINE_string 'ssid' 'SmartAP' 'SSID to use for the Access Point' 's'
DEFINE_string 'password' 'SuperSecret' 'Password to use for the Access Point' 'p'
DEFINE_string 'device' 'wlan0' 'Wireless LAN Device Name' 'd'

FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

echo "Device: ${FLAGS_device}"
echo "SSID: ${FLAGS_ssid}"
echo "Encryption: WPA2"
echo "Authentication: PresharedKey"
echo "Channel: 1"
echo "Mode: 802.11g"
echo "Password: ${FLAGS_password}"

device=${FLAGS_device}
ssid=${FLAGS_ssid}
psk=${FLAGS_password}

# a basic config file is very straight-forward
cat > hostapd.conf << "EOF"
interface=AUTOREPLACE_DEVICE
driver=nl80211
ssid=AUTOREPLACE_SSID
channel=1
hw_mode=g

wpa=2
wpa_passphrase=AUTOREPLACE_PSK
wpa_pairwise=CCMP TKIP
EOF
sed -e "s;AUTOREPLACE_DEVICE;$device;g" \
    -e "s;AUTOREPLACE_SSID;$ssid;g" \
    -e "s;AUTOREPLACE_PSK;$psk;g" \
    -i hostapd.conf

echo "Finished Generating hostapd.conf"
