dmidecode -t  slot |grep -i Designation: |cut -f 2 -d ":" >.11.txt
dmidecode -t  slot |grep -i "Bus Address:" |cut -f 3 -d " " |cut -c 6-12 >.bus.txt
aa=`dmidecode -t  slot |grep -i Designation |grep "#"`
dmidecode -t  slot |grep -i "current usage:" |cut -f 2 -d ":" >.12.txt
dmidecode -t  slot |grep -i "Type:" |cut -f 2 -d ":" >.bb.txt
bb=`lspci -v |grep -i net |grep -B 1 Subsystem:  |grep -v \( |uniq`
#bb=`lspci -v |grep -i net |grep -B 1 Subsystem:`
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
b=`lspci -v |grep -i net |grep -B 1 Subsystem: |awk '{print $1}' |grep -vi subsystem: |cut -f1  -d "." |uniq |sed 's/[ ]/|/g'`
c=`lspci -v |grep -i net |grep -B 1 Subsystem: |awk '{print $1}' |grep -vi subsystem: |cut -f1  -d "." |uniq |sed 's/[ ]/|/g' |wc -l`


#cat .14.txt  |grep "$b" >.15.txt
cat .14.txt  |grep "$b" |awk '{$1="";print $0"  *"}' >.15.txt
#lspci -v |grep -i net |grep 0.0 |awk '{print  $1}' >.a.txt
#lspci -v |grep -i net |grep -B 1 Subsystem: |awk '{print $1}' |grep -vi subsystem: |uniq |grep 0.0 >.a.txt
 #lspci -v |grep -i net |grep -B 1 Subsystem: |grep 0.0 |awk '{print  $1}' >.a.txt

lspci -v |grep -i net  |grep -iE '0.0|Subsystem:' |uniq |grep -B 1 Subsystem: |grep -vE 'X722|Connection|Network|Gigabit'  >.b.txt
#awk '!(NR%2)' .b.txt >.c.txt
#cat .b.txt  |grep -vE "$b" |uniq |awk '(NR%2)' |awk '{print $NF}' >.pci.txt
#if [ "$b" == 2 ]
#then

cat .b.txt  |grep -vE "$b" |awk '{print $NF}' >.pci.txt   #把偶数去掉了
#paste .a.txt .c.txt >.test.txt
#paste .a.txt .c.txt >.pci.txt
#for i in `cat .bus.txt` ;do cat .test.txt |grep $i ;done >.pci.txt
#for i in `cat .bus.txt` ;do cat .test.txt |grep $i ;done |awk '{print $1,$NF}' >.pci.txt


#c=`paste .15.txt .pci.txt | awk -F "${b}.0" '{print $2"*"$3}'`
if [ -s .15.txt ]
then
pt=`lspci -v |grep net |grep '82571EB Gigabit' |awk '{print $1}' |cut -f1 -d '.' |uniq`
#c=`paste .15.txt .pci.txt`
paste .15.txt .pci.txt >.pcie.txt
if [ -n "$pt" ]
then

dmidecode -t slot |grep -E "Designation:|Bus Address:"  |grep -B 1 $pt |grep -v $pt |awk '{$1="";print $0"  *    9402PT "}' >>.pcie.txt
else
echo "" | grep -v "^$"
fi
echo  "`cat .pcie.txt`"
else
lspci |grep 5959:1004  |awk -F '(' '{print $1}' |awk -F '5959:' '{print "C"$2}' |xargs |sed 's/$/ */g' >.16.txt

cat .pci.txt |xargs  >.pci-1.txt
if [ -s .16.txt ]
then
c=`cat  .pci-1.txt |grep -v 10GBASE-T |grep -vE 'X722|Connection|Network|Gigabit'` 
else
c=`paste .16.txt .pci-1.txt |grep -v 10GBASE-T |grep -vE 'X722|Connection|Network|Gigabit'` 

fi
echo  "$c"
fi
fi
else
echo "" | grep -v "^$"
fi
#rm -rf .*.txt
