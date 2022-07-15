#!/bin/bash
b=`ls /dev/ipmi0 2>/dev/null`

if [ ! -f $b ]; then


fan_mode=`./shell/IPMICFG-Linux.x86_64 -fan |grep -i  'Current Fan' |grep -o  '\[.*\]' |tr -d '[]' 2>/dev/null`
echo "$fan_mode"
else
	 echo "" | grep -v "^$"
 fi
 rm -rf ./.*.txt ./*.txt

