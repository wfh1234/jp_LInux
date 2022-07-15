a=`ip a |grep -i up |grep -v lo |grep -v vir* |awk '{print $2}' |cut -f1 -d ':' 2>/dev/null  |sed -n 1p`
ifup $a >/dev/null 2>&1
sleep 4
apt install eject ipmitool  parted smartmontools ethtool net-tools lsscsi -y >/dev/null 2>&1

yum install eject ipmitool  parted smartmontools ethtool net-tools lsscsi -y >/dev/null 2>&1



