dmidecode -t  slot |grep -i Designation: |cut -f 2 -d ":" >.11.txt
dmidecode -t  slot |grep -i "Bus Address:" |cut -f 3 -d " " |cut -c 6-12 >.bus.txt
aa=`dmidecode -t  slot |grep -i Designation |grep "#"`
dmidecode -t  slot |grep -i "current usage:" |cut -f 2 -d ":" >.12.txt
dmidecode -t  slot |grep -i "Type:" |cut -f 2 -d ":" >.bb.txt
#bb=`lspci -v |grep -i net |grep -B 1 Subsystem:  |grep -v \( |uniq`
bb=`lspci -v |grep -iE 'HBA|FIBRE'  |grep -i '0.0' |uniq |awk '{print $1}' |sed -n 1p`
if [ -n "$bb" ]
then
if [ -z "$aa" ]
then
paste  .bus.txt .11.txt .12.txt >.13.txt
else
paste .bus.txt .11.txt |tr -d [#] >aa.txt
paste aa.txt .bb.txt .12.txt >.13.txt
fi
a=`cat .13.txt |grep -i "in use"`
if [ ! -n "$a" ]
then
	 echo "" | grep -v "^$"
else
echo
cat .13.txt |grep -i "in use" |awk  -F "In" '{print $1}' >.14.txt
b=`lspci -v |grep -iE 'HBA|FIBRE'  |grep -i '0.0' |uniq |awk '{print $1}'`
#c=`lspci -v |grep -i net |grep -B 1 Subsystem: |awk '{print $1}' |grep -vi subsystem: |cut -f1  -d "." |uniq |sed 's/[ ]/|/g' |grep -v '\--' |wc -l`


#cat .14.txt  |grep "$b" >.15.txt
cat .14.txt  |grep "$b" |awk '{$1="";print $0}'  >.15.txt
A=`cat .15.txt |grep PCI-E`
if [ -z "$A" ] ;then
dmidecode -t slot |grep -A 1 "Designation:"  |grep -v "\--" |awk -F ":" '{print $2}' |sed 'N;s#\n# #g' |awk -F "PCI" '{print $1}' >.16.txt
 aa=`cat .15.txt`

echo  "`cat .16.txt |grep  "$aa"`"

else
echo  "`cat .15.txt`"
fi

fi
else
echo "" | grep -v "^$"
fi
#rm -rf .*.txt
