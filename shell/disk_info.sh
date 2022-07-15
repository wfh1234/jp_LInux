LANG=en_US.UTF-8 >/dev/null
a=`ip a |grep -i up |grep -v lo |grep -v vir* |grep -v 'qdisc pfifo_fast state UNKNOWN group' |grep -v 'qdisc fq_codel state UNKNOWN group' |awk '{print $2}' |cut -f1 -d ':' 2>/dev/null  |sed -n 1p`
ifup $a >/dev/null 2>&1
sleep 2
apt install eject ipmitool lshw  parted smartmontools ethtool net-tools lsscsi nvme-cli -y >/dev/null 2>&1

yum install eject ipmitool lshw  parted smartmontools ethtool net-tools lsscsi nvme-cli -y >/dev/null 2>&1


rm -rf .n.txt .fw.txt .m.txt .size.txt .sn.txt >/dev/null  2>&1

apt install nvme-cli  -y >/dev/null 2>&1 ; yum install nvme-cli -y >/dev/null 2>&1

#c=`paste .15.txt .pci.txt`
#echo -e "$c"
#disk=`lsscsi |grep -iE 'INTEL|ST|Samsung|SATADOM|SATA|SAS|ATA' |grep -vE 'Logical Volume|-' |   awk '{$1="";$2="";$3="";print $0}' |awk '{print $NF}'`
disk=`lsscsi |grep -iE 'INTEL|ST|Samsung|SATADOM|SATA|SAS|ATA' |grep -vE 'Logical Volume' |   awk '{$1="";$2="";$3="";print $0}' |awk '{print $NF}' |grep -E '[0-9a-zA-Z]$'`
if [ -n "$disk" ]
then
#nvme list |grep nvme |awk -F 'TB' '{print $1"TB"}' |awk '{print $NF}' ;for i in `echo $disk` ;do smartctl -a $i |grep 'User Capacity:' |awk  -F 'bytes' '{print $2}' |tr -d '[] ' ;done >.size.txt
nvme list |grep nvme |awk '{print $2}' >>.sn.txt ;for i in `echo $disk`  ;do smartctl -a $i |grep -i 'Serial Number:' |cut -f2 -d ":" ;done  >>.sn.txt

nvme list |grep nvme |awk '{print $1}' >.nvme.txt
for i in `cat .nvme.txt` ;do smartctl -a $i |grep 'Total NVM Capacity:' |cut -f 2 -d  '[' |tr -d ']' |sed 's/[ ]//g'  ;done >>.size.txt ;for i in `echo $disk` ;do smartctl -a $i |grep 'User Capacity:' |awk  -F 'bytes' '{print $2}' |tr -d '[] ' ;done >>.size.txt

for i in `cat .nvme.txt` ;do smartctl -a $i |grep 'Model Number:' |cut -f 2 -d ":" |sed 's/[ ][ ]*//g' ;done >>.n.txt ; for i in $disk ;do smartctl -a $i |grep -E "Device Model:|Product:" |awk -F ':' '{print $2}' |sed 's/...GB$//g' |sed 's/...TB$//g'  |sed 's/^[ ]*//g' |sed 's/ /-/g'  |sed 's/-$//g' ;done  |sed 's/BR-32GB/MSATA/g'  >>.n.txt

 nvme list |grep nvme |awk '{print $1}' >>.m.txt ; lsscsi |grep -iE 'INTEL|ST|Samsung|SATADOM|SATA|SAS|ATA' |grep -v 'Logical Volume' |grep -v sr0 |   awk '{$1="";$2="";$3="";print $0}' |awk '{print $NF}' >>.m.txt
nvme list |grep nvme |awk '{print $NF}' >>.fw.txt ; lsscsi |grep -iE 'INTEL|ST|Samsung|SATADOM|SATA|SAS|ATA' |grep -v 'Logical Volume' |grep -v sr0 | awk '{$1="";$2="";$3="";print $0}' |awk '{print $(NF-1)}'  >>.fw.txt
disk1=`paste .n.txt .fw.txt .m.txt .size.txt .sn.txt |grep -E '[0-9A-Za-z]$'`
echo  "$disk1" |sed 's/INTEL-SSDSC2KB240G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB480G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB960G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB[0-9A-Z]\+[GT]8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]8/INTEL-S4610/g'| sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]7/INTEL-S4600/g'
#rm -rf ./.*.txt ./.*.txt
else
echo "" | grep -v "^$"
fi
