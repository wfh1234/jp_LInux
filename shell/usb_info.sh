#!/bin/bash
#xujinrong
#date 2017-03-23
#Big disk size
#BIG_DISK_SIZE=`fdisk -l /dev/sda  2>/dev/null |awk '$1=="255"{cylinders = $5;print cylinders}'`
LANG=en_US.UTF-8 >/dev/null
#SYS_ROOT=`cat /etc/fstab | grep / |grep UUID |awk '{print $1}'|awk -F"=" '{print $2}'|head -n 1`
SYS_ROOT=`cat /etc/fstab | grep -v ^# |grep -v swap |grep -i UUID |awk '{print $1}' |sed 's#/dev/disk/by-uuid/#UUID=#g'| awk -F"=" '{print $2}'|head -n 1`
#SYS_DISK=`ls -l /dev/disk/by-uuid/${SYS_ROOT} |awk '{print $11}'|awk -F"../" '{print $3}'`
#SYS_DISK_SIZE=`fdisk -l /dev/$SYS_DISK 2>/dev/null|grep Disk |head -1 |awk '{print $3}' |awk -F. '{print $1}'`
SYS_DISK=`ls -l /dev/disk/by-uuid/${SYS_ROOT} |awk '{print $11}'|awk -F"../" '{print $3}' |sed 's/[0-9]$//g'`
#SYS_DISK_SIZE=`fdisk -l /dev/$SYS_DISK 2>/dev/null|grep Disk |head -1 |awk '{print $3}' |awk -F. '{print $1}'`
#SYS_DISK_SIZE=`lsblk -ln |grep $SYS_DISK  |head -n1 |awk '{print $4}' |tr -d '[A-Z]' |cut -f 1 -d '.'`
a=`fdisk -l |grep $SYS_DISK  |head -n1 |awk '{print $3}' |cut -f 1 -d '.'`
SYS_DISK_SIZE=`if [ "$a" -lt 30 ] ;then expr "$a" \* 1024 ;else echo $a ;fi`


disk=`fdisk  -l|grep 'Disk /dev/sd'|awk -F ',' '{print $1}'  |awk '{print $2"\t"$3""$4}'  |grep -E "30.8|61.5|57.29|57.3|14.7|28.7" |awk -F ":" '{print $1"  "$2}'  |cut -f 1`
for i in `echo $disk`
do
dd if=$i of=/dev/null bs=1M count=100 >.log.txt 2>&1 >.log.txt
a=`cat .log.txt |grep MB |awk '{print $(NF-1)}' |cut -f1 -d "."`
if [ $a -gt 50 ] ;then
echo  "USB3.0 * OK"
else
echo   "USB2.0 * OK"
fi
done
rm -rf storcli.log* >/dev/null
rm -rf storelibdebugit.txt.1 >/dev/null
rm -rf ../storcli.log* >/dev/null
rm -rf ../storelibdebugit.txt.1 >/dev/null



