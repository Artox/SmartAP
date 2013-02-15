#!/bin/sh

# starts hostapd and blocks until it ends
hostapd_args="$@"

# start process in background
hostapd $hostapd_args &
pid=$!

# wait for background job to finish
wait $pid
