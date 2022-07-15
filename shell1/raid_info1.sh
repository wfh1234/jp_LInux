#! /bin/bash
#DATA DISK
#RAID CARD

rpm -i ./shell/storcli-007.1410.0000.0000-1.noarch.rpm  >/dev/null 2>&1
rpm -i ./shell/storcli-007.1410.0000.0000-1.aarch64.rpm >/dev/null 2>&1

dpkg -i ./shell/storcli_007.1410.0000.0000_all.deb >/dev/null 2>&1
dpkg -i ./shell/storcli64_007.1410.0000.0000_arm64.deb >/dev/null 2>&1
scp -r  /opt/MegaRAID/storcli/storcli64 /usr/bin/storcli >/dev/null 2>&1
chmod 755 /opt/MegaRAID/storcli/storcli 2>/dev/null
scp -r /opt/MegaRAID/storcli/storcli /usr/bin/storcli >/dev/null 2>&1


raid=`storcli /c0 show all |grep "Model =" |grep -v Yes 2>/dev/null`
if [ ! -n "$raid" ]; then
	        echo "" | grep -v "^$"
	else
		r=`storcli /c0 show all |grep '^Model =' |awk '{print $NF}'`
		#v0
		status=`storcli /c0 /v0 show all |grep ^Status |awk -F '= ' '{print $2}'`
		hba=`storcli /c0 show  |grep 'Product Name' |awk -F "=" '{print $2}' |awk '{print $2}'`

		if [ ! -z $status -a "$hba" != 9400-8i -a -n "$hba"  ]
		then
				storcli /c0 /v0 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null >id.txt
				storcli /c0 /v0 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null >ID.txt
				storcli /c0  /v0 show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"\t"$7"\t"$5""$6"     "$3}' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null >r.txt

raid_info=`paste id.txt r.txt`
				paste  id.txt ID.txt |awk '{print $1" "$2"   "$3}' >slot.txt
				storcli /c0 /v0 show all |grep RAID |awk '{print $2"\t"$9"TB""    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $1}' >3.txt
				storcli /c0 /v0 show all |grep RAID |awk '{print $2"\t"$9""$10"    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $2}' >4.txt
				storcli /c0 /v0 show all |grep RAID |awk '{print $2"\t"$9"TB""    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $3}' >5.txt
				num=`cat id.txt |wc -l`
				storcli /c0 /eall /sall show all |grep "Firmware Revision =" |sed -n 1,${num}p |awk -F "=" '{print $2}' 2>/dev/null >a.txt
				storcli /c0 /eall /sall show all |grep "Drive Temperature =" |sed -n 1,${num}p |awk -F "=" '{print $2}' |awk '{print $1}' 2>/dev/null >i.txt
				storcli /c0 show all |grep "Model =" |grep -v Yes |awk -F "=" '{print $2}' |awk '{print $1}' >1.txt
				storcli /c0 show all |grep "Model =" |grep -v Yes |awk -F "=" '{print $2}' |awk '{print $3"-"$4}' >2.txt
				storcli /c0 show all |grep "Firmware Version =" |grep -v Yes |awk -F "=" '{print $2}' >6.txt
				storcli /c0 show all |grep "On Board Memory Size"  |awk -F "=" '{print $2}' >7.txt
				#echo -e       "\033[36m Brand: Slot:ID:  Model:                 type:    Size:      status:   Revision:       cache/temp: \033[0m"  >bb.txt
				#echo -e       "\033[36m ------------------------------------------------------------------------------------------------ \033[0m"  >>bb.txt
				firmware=`storcli /c0 show all |grep "Firmware Version =" |grep -v Yes |awk -F "=" '{print $2}'`


count=`for i in 0 1 2 ;do storcli /c0 /v${i} show all |grep RAID |awk '{print $2"\t"$9"TB""    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $3}' ;done |wc -l`

if [ "$count" == "3" ]
then

raid_status=`for i in 0 1 2 ;do storcli /c0 /v${i} show all |grep RAID |awk '{print $2"\t"$9"TB""    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $3}' ;done |tr '\n' ' ' |awk '{print "VD0: "$1"        VD1: "$2"        VD2: "$3}'`
raid_level=`for i in 0 1 2 ;do storcli /c0 /v${i} show all |grep RAID |awk '{print $2"\t"$9"TB""    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $1}' ;done |tr '\n' ' ' |awk '{print "VD0: "$1"        VD1: "$2"        VD2: "$3}'`
raid_size=`for i in 0 1 2 ;do storcli /c0 /v${i} show all |grep RAID |awk '{print $2"\t"$9""$10"    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $2}' ;done |tr '\n' ' ' |awk '{print "VD0: "$1"        VD1: "$2"        VD2: "$3}'`
raid_wb=`for i in 0 1 2 ;do storcli /c0 /v${i} show all |grep 'Write Cache(initial setting)' |cut -f 2 -d "=" ;done |tr '\n' ' ' |awk '{print "VD0: "$1"        VD1: "$2"        VD2: "$3}'`
a=`storcli /c0 show all |grep "Model =" |grep -v Yes |awk     -F "=" '{print $2}' |awk '{print $3"-"$4}' |awk -F '-' '{print $2"-"$3}'`
				raid_dev=`lsscsi |grep $a |awk '{print $NF}' |tr '\n' ' ' |awk '{print "VD0: "$1"        VD1: "$2"        VD2: "$3}'`
elif [ "$count" == "2" ]
then
raid_status=`for i in 0 1 2 ;do storcli /c0 /v${i} show all |grep RAID |awk '{print $2"\t"$9"TB""    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $3}' ;done |tr '\n' ' ' |awk '{print "VD0: "$1"        VD1: "$2}'`
raid_level=`for i in 0 1 2 ;do storcli /c0 /v${i} show all |grep RAID |awk '{print $2"\t"$9"TB""    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $1}' ;done |tr '\n' ' ' |awk '{print "VD0: "$1"        VD1: "$2}'`
raid_size=`for i in 0 1 2 ;do storcli /c0 /v${i} show all |grep RAID |awk '{print $2"\t"$9""$10"    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $2}' ;done |tr '\n' ' ' |awk '{print "VD0: "$1"        VD1: "$2}'`
raid_wb=`for i in 0 1 2 ;do storcli /c0 /v${i} show all |grep 'Write Cache(initial setting)' |cut -f 2 -d "=" ;done |tr '\n' ' ' |awk '{print "VD0: "$1"        VD1: "$2}'`
a=`storcli /c0 show all |grep "Model =" |grep -v Yes |awk     -F "=" '{print $2}' |awk '{print $3"-"$4}' |awk -F '-' '{print $2"-"$3}'`

 raid_dev=`lsscsi |grep $a |awk '{print $NF}' |tr '\n' ' ' |awk '{print "VD0: "$1"        VD1: "$2}'`

else

raid_status=`for i in 0 1 2 ;do storcli /c0 /v${i} show all |grep RAID |awk '{print $2"\t"$9"TB""    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $3}' ;done |tr '\n' ' ' |awk '{print "VD0: "$1}'`
raid_level=`for i in 0 1 2 ;do storcli /c0 /v${i} show all |grep RAID |awk '{print $2"\t"$9"TB""    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $1}' ;done |tr '\n' ' ' |awk '{print "VD0: "$1}'`
raid_size=`for i in 0 1 2 ;do storcli /c0 /v${i} show all |grep RAID |awk '{print $2"\t"$9""$10"    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $2}' ;done |tr '\n' ' ' |awk '{print "VD0: "$1}'`
raid_wb=`for i in 0 1 2 ;do storcli /c0 /v${i} show all |grep 'Write Cache(initial setting)' |cut -f 2 -d "=" ;done |tr '\n' ' ' |awk '{print "VD0: "$1}'`
a=`storcli /c0 show all |grep "Model =" |grep -v Yes |awk     -F "=" '{print $2}' |awk '{print $3"-"$4}' |awk -F '-' '{print $2"-"$3}'`
 raid_dev=`lsscsi |grep $a |awk '{print $NF}' |tr '\n' ' ' | awk '{print "VD0: "$1}'`
fi




				raid_sn=`storcli /c0 show all |grep 'Serial Number =' |cut -f2 -d "="`
 				raid_model=`storcli /c0 show all |grep "Model =" |grep -v Yes |awk -F "=" '{print $2}' |awk '{print $3"-"$4}'`
				raid_cache=`storcli /c0 show all |grep "On Board Memory Size"  |awk -F "=" '{print $2}'`
				bbu_type=`storcli /c0/cv show all |grep 'Type' |awk '{print $2}'`
storcli /c0/cv show all |grep '^State' |awk '{print $2}'  >.1.txt
storcli /c0/cv show all |grep '^Temperature' |awk '{print "电池温度："$2"度"}' >.2.txt

				bbu_status=`paste .1.txt .2.txt`

lspci -v |grep -i sas |grep -iE '0.0|Subsystem:' >.33.txt
lspci -v |grep -i sas |grep -iE 0.0 |awk '{print $1}' >.22.txt
awk '!(NR%2)' .33.txt >.44.txt
paste .22.txt .44.txt  |awk '{print $1}' >.55.txt
paste .22.txt .44.txt  |awk -F '/' '{print $2}'  >.66.txt
paste .55.txt .66.txt | grep -vE '9311|9211|9300|9400' >.pci.txt
for i in `cat .22.txt` ;do cat .pci.txt |grep $i ;done >.23.txt
pci=`cat .23.txt |awk '{print $1}' |sed 's/[ ]/|/g'`

dmidecode -t  slot |grep -i Designation: |cut -f 2 -d ":" >.11.txt
dmidecode -t  slot |grep -i "Bus Address:" |cut -f 3 -d " " |cut -c 6-12 >.bus.txt
aa=`dmidecode -t  slot |grep -i Designation |grep "#"`
dmidecode -t  slot |grep -i "current usage:" |cut -f 2 -d ":" >.12.txt
dmidecode -t  slot |grep -i "Type:" |cut -f 2 -d ":" >.bb.txt
if [ ! -z "$aa" ]
then

paste  .bus.txt .11.txt .12.txt >.13.txt
else
paste .bus.txt .11.txt |tr -d "#" >.aa.txt
#paste .aa.txt .bb.txt .12.txt >.13.txt
paste .aa.txt  .12.txt >.13.txt
fi
a=`cat .13.txt |grep -i "in use"`
if [ ! -n "$a" ]
then
         echo "" | grep -v "^$"
else

cat .13.txt |grep -i "in use" |awk '{print $1"    "$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8}' |awk  -F "In" '{print $1}' >.14.txt
hba=`storcli /c0 show  |grep 'Product Name' |awk -F "=" '{print $2}' |awk '{print $NF}'`

pci1=`lspci -v |grep -i sas |grep -B 1 $hba |grep -v "\--" |sed -n 1p |awk '{print $1}'`
pcie1=`cat .14.txt |grep "$pci1" |awk '{$1="";print $0}'`
fi

A=`cat .14.txt |grep PCI-E`
if [ -z "$A" ] ;then
dmidecode -t slot |grep -A 1 "Designation:"  |grep -v "\--" |awk -F ":" '{print $2}' |sed 'N;s#\n# #g' |awk -F "PCI" '{print $1}' >.16.txt

 cat .16.txt |grep  "$pcie1" |sed 's/^[ \t]*//g' >.17.txt

else
#cat .14.txt |sed 's/^[ \t]*//g' >.17.txt
cat .14.txt |grep "$pci" |awk '{$1="";print $0}' >.17.txt
fi


pcie=`cat .17.txt`




#pcie=`cat .14.txt |grep $pci |awk '{$1="";print $0}'`
#pcie=`cat .14.txt |grep "$pci" |awk '{$1="";print $0}' |uniq`



echo  "raid_info: $firmware*$raid_status*$raid_level*$raid_size*$raid_dev*$raid_sn*$raid_model*$raid_cache*$bbu_type*$bbu_status*$raid_wb*$pcie"





				storcli /c0 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null >id.txt

if [ -n id.txt ]
then
 echo "" | grep -v "^$"
else
				storcli /c0 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null >ID.txt
				storcli /c0 show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"\t"$7"\t"$5""$6"     "$3}' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null >r.txt
				cat r.txt |cut -c 1-2 |sed 's/ST/ Seagate:/g' >p.txt
				paste p.txt id.txt ID.txt |awk '{print $1" "$2"   "$3}' >slot.txt
				storcli /c0 /eall /sall show all |grep "Firmware Revision =" |awk -F "=" '{print $2}' 2>/dev/null >a.txt
#				storcli /c0 /eall /sall show all |grep "Drive Temperature =" |awk -F "=" '{print $2}' |awk '{print $1}' 2>/dev/null >i.txt
				storcli /c0 show all |grep "Model =" |grep -v Yes |awk -F "=" '{print $2}' |awk '{print $1}' >1.txt
				storcli /c0 show all |grep "Model =" |grep -v Yes |awk -F "=" '{print $2}' |awk '{print $3"-"$4}' >2.txt
				storcli /c0 show all |grep "Firmware Version =" |grep -v Yes |awk -F "=" '{print $2}' >6.txt
				storcli /c0 show all |grep "On Board Memory Size" |awk -F "=" '{print $2}' >7.txt
				paste 1.txt 2.txt  4.txt 5.txt 6.txt 7.txt 2>/dev/null >aa.txt
				cat aa.txt |awk '{print " "$1":            "$2"            "$3"\t"$4"     "$5"   "$6"\t"$7}' >>bb.txt
#				paste slot.txt  r.txt a.txt i.txt >>bb.txt
				paste slot.txt  r.txt a.txt >>bb.txt

				cat bb.txt
fi
				echo
			else
 echo "" | grep -v "^$"

			fi

fi

rm -rf /.nfs/*.txt
rm -rf ./.*.txt ./*.txt

rm -rf storcli.log* storelibdebugit.txt* >/dev/null
rm -rf ../storcli.log* ../storelibdebugit.txt* >/dev/null

