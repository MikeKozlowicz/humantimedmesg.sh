#!/bin/sh
# Translate dmesg timestamps to human readable format
# Intended for systems without 'dmesg -T' or 'dmesg -e'
# Like with 'dmesg -T', time will be inaccurate if system suspends/hibernates
# Tested with BusyBox (ash), dash, and bash

# set timezone
timezone="TZ=CST6CDT,M3.2.0,M11.1.0"

# desired date format
date_format="%a %b %d %T %Y"

# uptime in seconds
uptime=$(cut -d " " -f 1 /proc/uptime)

# current Unix time
now=$(date +%s)

# run only if timestamps are enabled
if [ "Y" = "$(cat /sys/module/printk/parameters/time)" ]; then
  dmesg | sed "s/^\[[ ]*\?\([0-9.]*\)\] \(.*\)/\\1 \\2/" | while read timestamp message; do
   time=$(echo $now $uptime $timestamp | awk '{ printf("%.0f\n", $1 - $2 + $3)}')
   printf "[%s] %s\n" "$(env $timezone date -d @"$time" +"${date_format}")" "$message"
  done
else
  echo "Timestamps are disabled (/sys/module/printk/parameters/time)"
fi

