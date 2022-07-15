
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



if [ $SYS_DISK_SIZE -gt 61 ]
then
c=`lsscsi |grep  'AVAGO|LSI' |awk '{print $NF}' |awk -F "/" '{print $NF}'`

a=`lsscsi |grep SanDisk |awk '{print $NF}' |cut -f 3 -d '/'`
b=`echo $a |sed 's# #|#g'`
lsblk -nl |grep -vE "${b}"  |awk '{print $1,$4,$7}' >.11.txt
if [ -n $c ]
then
 echo "" |grep -v "^#"
else
cat .11.txt |grep -v $c
fi
lsblk -lnf |grep -vE "${b}" |awk '{print $2}' >.12.txt
disk_info=`paste .11.txt .12.txt |grep -vE 'loop|sr0'`
echo  "$disk_info"
rm -rf ./.*.txt ./*.txt

else
 echo "" |grep -v "^#"
fi
