#!/bin/bash
#xjr
#2018-04-11
#rm -rf /.nfs/*.txt
rm -rf ./*.txt
rm -rf ./.*.txt

yum install pciutils net-tools  -y >/dev/null 2>&1
ip a |grep -i mtu |grep -v lo |grep -v vir* |grep -v 'qdisc fq_codel state UNKNOWN group' |grep -v 'qdisc pfifo_fast state UNKNOWN group' |awk '{print $2}' |tr -d ":" |sort -n >1.txt
#for i in `cat 1.txt` ;do ethtool $i |grep  Full |grep -vE 'Half|Duplex|link modes:' |awk -F 'base' '{print $1}' |uniq |tr -d [a-zA-Z/] |awk '{print $1"Mb/s"}' ;done >b.txt
# for i in `cat 1.txt` ;do ethtool $i |tr -d [a-zA-Z/:] |tr -d \(\)- |awk '{print $NF"Mb/s"}'|sort -n |uniq   ;done >b.txt
for i in `cat 1.txt` ;do ethtool $i |grep -v Settings | awk -F 'baseLR4/Full' '{print $1}' |awk -F 'baseSR4/Full' '{print $1}' |tr -d [a-zA-Z/:] |tr -d \(\)- |awk '{print $NF}' |grep 0$ |sort -n  |uniq |tail -n 1 |awk '{print $NF"Mb/s"}' ;done >b.txt
for i in `ip a |grep -i mtu |grep -v lo |grep -v vir* |grep -v 'qdisc fq_codel state UNKNOWN group' |grep -v 'qdisc pfifo_fast state UNKNOWN group'  |awk '{print $2}' |tr -d ":"` ;do ip a show $i |grep link/ether |awk '{print $2}' ;done  >hw.txt
lspci |grep Ethernet  |awk '{print $4}' >2.txt
lspci |grep Ethernet  |awk '{print $6}' >3.txt
lspci |grep Ethernet  |awk '{print $7}' >4.txt
lspci |grep Ethernet  |awk '{print $8}' >5.txt
if [ `lspci |grep Ethernet  |awk '{print $9}' |sed -n 1p` = "for" ]; then `lspci |grep Ethernet  |awk '{print $10}' >a.txt`; else echo "" | grep -v "^$"; fi >a.txt
lspci |grep -i eth |sed -r 's/0000://g' >ccc.txt
#dmesg |grep  Ethernet  |awk '{print $4" "$5}' |cut -f2-4  -d ":" >ddd.txt
#dmesg |grep  Ethernet  |awk '{print $4" "$5}' |cut -f2-4  -d ":" |grep '0.0' |awk '{print $1}' |sed 's/:$//' >d.txt
for i in `cat 1.txt` ;do ethtool -i $i |grep 'bus-info:' |awk -F '0000:' '{print $2}';done >d.txt
paste  d.txt  1.txt>ddd.txt
awk 'FNR==NR{a[$1]=$0;next;} {print a[$1]}' ccc.txt ddd.txt >11.txt
paste ddd.txt 11.txt >12.txt
#paste  1.txt hw.txt 6.txt 2.txt 3.txt 4.txt 5.txt a.txt
a=`cat b.txt |wc -l`
b=`cat 1.txt |wc -l`
if [ $a == $b ] ;then

#paste -d" " b.txt hw.txt 12.txt   |awk '{print "  "$1"   *"$2"   *  "$4" *  "$8,$9"   "$10"   "$11"  "$12"  "$13,$14,$15 }' |grep -iv br | cut -f1 -d "(" >aaa.txt

paste -d" " b.txt hw.txt 12.txt   |awk '{print "  "$1" *  "$2"  *   "$4" *  "$8,$9"   "$10"   "$11"  "$12"  "$13,$14,$15,$16,$17 }'  |awk -F "rev" '{print $1}' | sed 's/(//g'  |sed 's/.)//g' |sort -n >aaa.txt
a=`cat aaa.txt |awk '{print $1}'`
b=`cat aaa.txt |awk '{print $2}'`
c=`cat aaa.txt |awk '{print $3}'`
d=`cat aaa.txt |awk '{$1="";$2="";$3="";print $0}' |tr -d for`
echo  "`cat aaa.txt`"
#echo -e "network_info: $a*$b*$c*$d"

else
d=`expr $b / $a`
#for i in  `echo $d`
for ((i=1; i<=$d; i++))

do
echo 10000Mb/s >>b.txt
done
# paste -d" " b.txt hw.txt 12.txt   |awk '{print "  "$1"   "$2"     "$4"   "$8,$9"   "$10"   "$11"  "$12"  "$13,$15,$16 }' |grep -iv br |cut -f1 -d "("  >aaa.txt
paste -d" " b.txt hw.txt 12.txt   |awk '{print "  "$1" *  "$2"  *   "$4" *  "$8,$9"   "$10"   "$11"  "$12"  "$13,$14,$15,$16,$17 }'  |awk -F "rev" '{print $1}'  |sed 's/(//g'  |sed 's/.)//g' |sed -e 's/\[[^][]*\]//g' |sort -n >aaa.txt
a=`cat aaa.txt |awk '{print $1}'`
b=`cat aaa.txt |awk '{print $2}'`
c=`cat aaa.txt |awk '{print $3}'`
d=`cat aaa.txt |awk '{$1="";$2="";$3="";print $0}'`
echo  "`cat aaa.txt`"
#echo -e "network_info: $a*$b*$c*$d"

#rm -rf ./*.txt


fi
