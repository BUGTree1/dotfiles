#!/bin/sh

#pacmd list-sources | \
#grep -B1 '^.name: <.*\.monitor>' | \
#awk '/\* index/ {getline;monitor=$0} /[^\*] index/ {getline;if(fallback==""){fallback=$0}} END {print (monitor=="") ? fallback : monitor}' | \
#sed -E -e 's/^.name: <(.*)>$/\1/'

#echo "alsa_output.pci-0000_00_1f.3.analog-stereo.monitor"
echo "@DEFAULT_MONITOR@"
