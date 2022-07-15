#!/bin/bash
#xjr
#date 2018-04-11
b=`ls /dev/ipmi0 2>/dev/null`

if [ ! -f $b ]; then

fan=`ipmitool -I open  sdr |grep FAN |grep -v "no reading" |grep 'RPM' |awk '{print " "$1"          "$3" "$4"           "$6}' 2> /dev/null`
count=`ipmitool -I open  sdr |grep FAN |grep -v "no reading" |grep 'RPM' |awk '{print " "$1"          "$3" "$4"           "$6}' 2>/dev/null |wc -l`
echo
echo  "$fan"
else
 echo "" | grep -v "^$"
fi
rm -rf ./.*.txt ./*.txt
