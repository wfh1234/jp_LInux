yum install alsa-utils -y >/dev/null 2>&1
a=`aplay -l 2>/dev/null`
if [ -n "$a" ]
then
#yum remove pulseaudio -y >/dev/null 2>&1

sleep 3
aplay test.wav 2>/dev/null
aplay test.wav 2>/dev/null
echo  "音频测试结果： OK"
else
echo  "无"
fi

ip a |grep -i up |grep -v lo |grep -v vir* |grep -v 'qdisc fq_codel state UNKNOWN group' |grep -v 'qdisc pfifo_fast state UNKNOWN group'  |awk '{print $2}' |cut -f1 -d ':' 2>/dev/null >net.txt
for i in `cat net.txt` ;do ip a |grep inet |grep inet |grep $i |grep -v dynamic |awk '{print $2,$NF}' |cut -f 2 -d " " ;done >.net.txt


if [ -s .net.txt ]
then
for i in `cat net.txt` ;do sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/g' /etc/sysconfig/network-scripts/ifcfg-$i  ;done >/dev/null 2>&1
for i in `cat .net.txt` ;do ifup $i ;done  >/dev/null 2>&1
else


echo "" | grep -v "^$"
fi
rm -rf ./.*.txt
rm -rf ./*.txt
