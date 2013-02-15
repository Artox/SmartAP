#!/bin/sh

# starts udhcpd and blocks till it ends

pidfile=$1
udhcpd_args=`echo $@ | sed -e "s;$1;;g"`

echo $pidfile
echo $udhcpd_args

# launch udhcpd
udhcpd $udhcpd_args

# helper function to forwad sigint, sigterm
shutdown() {
	kill -s TERM $pid 2>/dev/null
}

# if pifdile exist we started successfully
if [ -e "$pidfile" ]; then

	# get pid
	pid=`cat $pidfile`

	# catch sigint, sigterm
	trap shutdown INT TERM

	# wait for udhcpd to terminate
	# this is an ugly way but I didnt find a better yet
	# udhcpd just wont run in foreground
	dead=0
	while [ $dead -eq 0 ]; do
		sleep 1
		kill -0 "$pid" 2>/dev/null
		dead=$?
	done
fi
