LANG=en_US.UTF-8 >/dev/null
a=`ip a |grep -i up |grep -v lo |grep -v vir* |grep -v 'qdisc fq_codel state UNKNOWN' |grep -v 'qdisc pfifo_fast state UNKNOWN group' |awk '{print $2}' |cut -f1 -d ':' 2>/dev/null  |sed -n 1p`
ifup $a >/dev/null 2>&1
sleep 2

a=`uname -r |grep el7`
b=`uname -r |grep el8`
if [ -n "$b" ]
then
mkdir /etc/yum.repos.d/bak >/dev/null 2>&1
mv  /etc/yum.repos.d/CentOS-*  /etc/yum.repos.d/bak  >/dev/null 2>&1
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo  >/dev/null 2>&1
else
echo "" | grep -v "^$"
fi


ip a |grep -i up |grep -v lo |grep -v vir* |grep -v 'qdisc fq_codel state UNKNOWN group' |grep -v 'qdisc pfifo_fast state UNKNOWN group' |awk '{print $2}' |cut -f1 -d ':' 2>/dev/null >net.txt
for i in `cat net.txt` ;do ip a |grep inet |grep inet |grep $i |grep -v dynamic |awk '{print $2,$NF}' |cut -f 2 -d " " ;done >.net.txt

for i in `cat net.txt` ;do sed -i 's/BOOTPROTO=static/BOOTPROTO=dhcp/g;s/BOOTPROTO=none/BOOTPROTO=dhcp/g' /etc/sysconfig/network-scripts/ifcfg-$i  ;done >/dev/null 2>&1

if [ -s .net.txt ]
then
for i in `cat .net.txt` ;do ifup $i ;done  >/dev/null 2>&1
else
echo "" | grep -v "^$"
fi

apt install eject ipmitool lshw  parted smartmontools ethtool net-tools lsscsi nvme-cli -y >/dev/null 2>&1

yum install eject ipmitool lshw  parted smartmontools ethtool net-tools lsscsi nvme-cli -y >/dev/null 2>&1


b=`ls /dev/ipmi0 2>/dev/null`
if [ -n "$b" ]
then
type=`ipmitool lan print |grep "IP Address Source" |cut -f 2 -d ":" |awk '{print $1}'`
ip=`ipmitool lan print |grep "IP Address" |grep -v "IP Address Source" |cut -f 2 -d ":" |awk '{print $1}'`
mac=`ipmitool lan print |grep "MAC Address " |awk '{print $4}'`
firmware=`ipmitool  mc info |grep "Firmware Revision" |cut -f 2 -d ":"`
echo   "ipmi_info: $ip*$type*$mac*$firmware"
else
echo "" | grep -v "^$"
fi

