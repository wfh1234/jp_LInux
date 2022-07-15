#!/bin/bash
#xjr
#2018-04-11
#rm -rf /.nfs/*.txt



echo
sleep 4
ip a |grep -i up |grep -v lo |grep -v vir* |grep -v 'qdisc fq_codel state UNKNOWN group' |grep -v 'qdisc pfifo_fast state UNKNOWN group' |awk '{print $2}' |cut -f1 -d ':' |sort -n 2>/dev/null >net.txt
for i in `cat net.txt` ;do ip a |grep inet |grep inet |grep $i |grep -v dynamic |awk '{print $2,$NF}' |cut -f 2 -d " " ;done >.net.txt

for i in `cat net.txt` ;do sed -i 's/BOOTPROTO=static/BOOTPROTO=dhcp/g;s/BOOTPROTO=none/BOOTPROTO=dhcp/g' /etc/sysconfig/network-scripts/ifcfg-$i  ;done >/dev/null 2>&1
service network restart >/dev/null 2>&1
for i in `cat net.txt`
do
ifup $i >/dev/null 2>&1
ifconfig $i |grep 192.168.19 >eth.txt
sleep 4
ping 192.168.19.1 -c 10 -i 0.3 >.log.txt
num=`cat .log.txt |grep "10 packets" |grep 0% |awk '{print $1}'`

ethtool=`ethtool $i |grep Speed: |cut -f2 -d ":"`
eth=`ethtool $i |grep Speed: |cut -f2 -d ":" |tr -d 'Mb/s[0-9]'`
if [ ! -z $eth ] ;then
echo  "$i $ethtool Failed"
ifdown $i >.log.txt 2>&1
ifdown $i >.log.txt 2>&1
#ip addr del 192.168.19.1/24 dev $i >.log1.txt 2>&1
elif [ ! -z $num ] ;then
echo  " $i $ethtool   OK"
ifdown $i >.log.txt 2>&1
ifdown $i >.log.txt 2>&1
else
echo  " $i $ethtool   OK"
ifdown $i >.log.txt 2>&1
ifdown $i >.log.txt 2>&1


fi

done


if [ -s .net.txt ]
then
for i in `cat .net.txt` ;do ifup $i ;done  >/dev/null 2>&1
else
a=`ip a |grep -i up |grep -v lo |grep -v vir* |grep -v 'qdisc fq_codel state UNKNOWN group' |awk '{print $2}' |cut -f1 -d ':' 2>/dev/null  |sed -n 1p`
ifup $a >/dev/null 2>&1
#echo "" | grep -v "^$"
fi



rm -rf ./*.txt
rm -rf ./.*.txt
