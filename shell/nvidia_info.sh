#!/bin/bash
#xjr
#2018-04-11
rm -rf ./.*.txt
dmidecode -t  slot |grep -i Designation: |cut -f 2 -d ":" >.11.txt
dmidecode -t  slot |grep -i "Bus Address:" |cut -f 3 -d " " |cut -c 6-12 >.bus.txt
aa=`dmidecode -t  slot |grep -i Designation |grep "#"`
dmidecode -t  slot |grep -i "current usage:" |cut -f 2 -d ":" >.12.txt
dmidecode -t  slot |grep -i "Type:" |cut -f 2 -d ":" >.bb.txt
if [ -z "$aa" ]
then
paste  .bus.txt .11.txt .12.txt >.13.txt
else
cat .bus.txt .11.txt |tr -d [#] >.aa.txt
paste aa.txt bb.txt .12.txt >.13.txt
fi
a=`cat .13.txt |grep -i "in use"`
if [ ! -n "$a" ]
then
	 echo "" | grep -v "^$"
else
cat .13.txt |grep -i "in use" |awk '{print $1"    "$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8}' |awk  -F "In" '{print $1}' >.14.txt

b=`lspci -vnn | grep VGA -A 12 |grep VGA |cut -f 3 -d ":" |awk '{print $1"\t"$2"\t"$3}' |grep ^NVIDIA |awk '{print $1}' |sed -n 1p`
if [ ! -f $b ] ; then
	nvidia-smi -pm 1 >/dev/null
	dmidecode -t slot |grep 'Bus Address:' |awk '{print "0000"$3}' >.1.txt
	dmidecode -t slot |grep 'Current Usage:' |cut -f2 -d ':' >.2.txt
	dmidecode -t slot |grep 'Designation:' |cut -f2 -d ':' >.3.txt
	paste .1.txt .2.txt  |grep -v Available |sort |cut -f 2-3 -d ":">.a.txt
	nvidia-smi -L |cut -f 1 -d "(" >.b.txt
	for i in `seq 0 7`;do nvidia-smi -i $i -q |grep 'Bus Id' ;done |awk -F ': ' '{print $2}'|cut -f 2-3 -d ":" >.c.txt
			        for i in `cat .c.txt` ;do paste .a.txt |grep -i $i ;done >.d.txt

		for i in `cat .c.txt` ;do paste .d.txt .b.txt |grep -i $i ;done |sed 's/In Use//g'  >.pci.txt
#		.pci=`for i in `cat .c.txt` ;do paste .d.txt .b.txt |grep -i $i ;done |sed 's/In Use//g'`
awk 'FNR==NR{a[$1]=$0;next;} {print a[$1]}' .pci.txt .14.txt |grep -v "^$" >.pci-e.txt

cat .pci-e.txt | awk '{$1=null;print $0}' |tr -d ":"  >.pci-ee.txt

#cat .14.txt |awk '{$1=null;print $0}' >.15.txt

aa=`cat .pci.txt  |awk '{print $1}'`

 cat .14.txt |grep "$aa"  |awk '{$1=null;print $0}'  > .15.txt


for i in `seq 0 7`;do nvidia-smi -i $i  -q |grep 'VBIOS Version'  |cut -f2 -d ":" ;done >.16.txt
for i in `seq 0 7`;do nvidia-smi -i $i  -q |grep 'Image Version' |cut -f2 -d ":" ;done >.17.txt
#pci=`paste .pci-ee.txt .15.txt .16.txt .17.txt`
a=`awk '{print "model: " $0}' .pci-ee.txt`
b=`awk '{print "pci-e: " $0}' .15.txt`
c=`awk '{print "vbios: " $0}' .16.txt`
d=`awk '{print "image: " $0}' .17.txt`

echo  "$a"
echo "$b"
echo "$c"
echo "$d"

		else
			echo "" | grep -v "^$"
		fi


fi
#rm -rf ./*.txt ./.*.txt
