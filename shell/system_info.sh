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
if [ $SYS_DISK_SIZE -gt 70 ]
then
b=`cat /etc/redhat-release 2>/dev/null  || cat /etc/kylin-release 2>/dev/null || cat /etc/issue |awk -F  'l' '{print $1}' |xargs |sed 's/n.$//' 2>/dev/null`

c=`uname -r`
LANG="zh_CN.UTF-8"
a=`date |uniq |sed 's/CST//g' |sed 's/年 /年/g;s/月 /月/g'`
d=`[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS |sed 's/BIOS/Legacy/g'`
echo  "$c*$d*$b*$a"

else
echo "" | grep -v "^$"
fi
