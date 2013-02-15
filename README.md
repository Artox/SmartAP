SmartAP
=======

Set of Tools for turning a PC into a Wireless Access Point
Currently limited to WPA2-PSK

Requires a wireless device driver based on mac80211 to function.

Usage:

./runap.sh

optional arguments can be queried by
./runap.sh --help

runap will start udhcpd as DHCP Server and hostapd for the Accesspoint

Pressing ctr+c once, the program will stop both of these services and then quit.
