#!/bin/bash
#xjr
#2018-04-11
#rm -rf /.nfs/*.txt

echo
sleep 4
ip a |grep -i up |grep -v lo |grep -v vir* |awk '{print $2}' |grep -v 82571EB |cut -f1 -d ':' 2>/dev/null |head -n 4 >net.txt


for i in `cat net.txt`
do
ifup $i >/dev/null 2>&1
ifconfig $i |grep 192.168.19 >eth.txt
sleep 4
ping 192.168.19.1 -c 10 -i 0.3 >.log.txt
num=`cat .log.txt |grep "10 packets" |grep 0% |awk '{print $1}'`

ethtool=`ethtool $i |grep Speed: |cut -f2 -d ":"`
if [ ! -z $num ] ;then
echo  " $i $ethtool   OK"
ifdown $i >.log.txt 2>&1
ifdown $i >.log.txt 2>&1
#ip addr del 192.168.19/24 dev $i >.log1.txt 2>&1
rm -rf ./*.txt
rm -rf ./*.txt
else
echo  "$i $ethtool Failed"
ifdown $i >.log.txt 2>&1
ifdown $i >.log.txt 2>&1
#ip addr del 192.168.19.1/24 dev $i >.log1.txt 2>&1
rm -rf ./*.txt
rm -rf ./*.txt

fi

rm -rf ./*.txt
rm -rf ./*.txt
done


a=`ip a |grep -i up |grep -v lo |grep -v vir* |awk '{print $2}' |cut -f1 -d ':' 2>/dev/null  |sed -n 1p`
ifup $a >/dev/null 2>&1
