#! /bin/bash
#DATA DISK
#RAID CARD

rpm -i ./storcli-007.1410.0000.0000-1.noarch.rpm  >/dev/null 2>&1
rpm -i ./storcli-007.1410.0000.0000-1.aarch64.rpm >/dev/null 2>&1

dpkg -i ./storcli_007.1410.0000.0000_all.deb >/dev/null 2>&1
dpkg -i ./storcli64_007.1410.0000.0000_arm64.deb >/dev/null 2>&1
scp -r  /opt/MegaRAID/storcli/storcli64 /usr/bin/storcli >/dev/null 2>&1
chmod 755 /opt/MegaRAID/storcli/storcli 2>/dev/null
scp -r /opt/MegaRAID/storcli/storcli /usr/bin/storcli >/dev/null 2>&1
cp -rf ./shell/sas3ircu /usr/bin >/dev/null 2>&1

cp -rf ./shell/sas2ircu /usr/bin >/dev/null 2>&1

a=`storcli /c0 show  |grep 'Product Name' |awk -F "=" '{print $2}' |awk '{print $NF}'`
b=`storcli /c1 show  |grep 'Product Name' |awk -F "=" '{print $2}' |awk '{print $NF}'`
if [ "$a" == SAS9311-8i -o "$a" == SAS9300-8i -o "$a" == SAS9400-8i ]
then
c=0
elif [ "$b" == SAS9311-8i -o "$b" == SAS9300-8i -o "$b" == SAS9400-8i ]
then
c=1
else
 echo "" | grep -v "^$"
fi



raid=`storcli /c$c show all |grep "Model =" |grep -v Yes 2>/dev/null`
if [ ! -n "$raid" ]; then
	        echo "" | grep -v "^$"
	else
		r=`storcli /c$c show all |grep '^Model =' |awk '{print $NF}'`
		#v0
		status=`storcli /c$c /v0 show all |grep ^Status |awk -F '= ' '{print $2}'`
         hba=`storcli /c$c show  |grep 'Product Name' |awk -F "=" '{print $2}' |awk '{print $NF}'`


	#	hba=`storcli /c0 show  |grep 'Product Name' |awk -F "=" '{print $2}' |awk '{print $NF}'`
		hba1=`storcli /c0 show  |grep 'Product Name'  |awk -F "=" '{print $2}' |tr -d [A-Z]`

		#if [ ! -z $status -a "$hba" = 9400-8i ]
		if [ "$hba" = 9400-8i ]
		then
				storcli /c$c /v0 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null >id.txt
				storcli /c$c /v0 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null >ID.txt
				storcli /c$c  /v0 show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"\t"$7"\t"$5""$6"     "$3}' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null >r.txt

raid_info=`paste id.txt r.txt`
				paste  id.txt ID.txt |awk '{print $1" "$2"   "$3}' >slot.txt
				storcli /c$c /v0 show all |grep RAID |awk '{print $2"\t"$9"TB""    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $1}' >3.txt
				storcli /c$c /v0 show all |grep RAID |awk '{print $2"\t"$9""$10"    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $2}' >4.txt
				storcli /c$c /v0 show all |grep RAID |awk '{print $2"\t"$9"TB""    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $3}' >5.txt
				num=`cat id.txt |wc -l`
				storcli /c$c /eall /sall show all |grep "Firmware Revision =" |sed -n 1,${num}p |awk -F "=" '{print $2}' 2>/dev/null >a.txt
				storcli /c$c /eall /sall show all |grep "Drive Temperature =" |sed -n 1,${num}p |awk -F "=" '{print $2}' |awk '{print $1}' 2>/dev/null >i.txt
				storcli /c$c show all |grep "Model =" |grep -v Yes |awk -F "=" '{print $2}' |awk '{print $1}' >1.txt
				storcli /c$c show all |grep "Model =" |grep -v Yes |awk -F "=" '{print $2}' |awk '{print $3"-"$4}' >2.txt
				storcli /c$c show all |grep "Firmware Version =" |grep -v Yes |awk -F "=" '{print $2}' >6.txt
				storcli /c$c show all |grep "On Board Memory Size"  |awk -F "=" '{print $2}' >7.txt
				#echo -e       "\033[36m Brand: Slot:ID:  Model:                 type:    Size:      status:   Revision:       cache/temp: \033[0m"  >bb.txt
				#echo -e       "\033[36m ------------------------------------------------------------------------------------------------ \033[0m"  >>bb.txt
				firmware=`storcli /c$c show all |grep "Firmware Version =" |grep -v Yes |awk -F "=" '{print $2}'`
				hba_sn=`storcli /c$c show all |grep 'Serial Number =' |cut -f2 -d "="`
 				hba_model=`storcli /c$c show all |grep "Model =" |grep -v Yes  |grep HBA |awk -F "=" '{print $2}'`

lspci -v |grep -i sas |grep -iE '0.0|Subsystem:' >.33.txt
lspci -v |grep -i sas |grep -iE 0.0 |awk '{print $1}' >.22.txt
awk '!(NR%2)' .33.txt >.44.txt
paste .22.txt .44.txt  |awk '{print $1}' >.55.txt
paste .22.txt .44.txt  |awk -F '/' '{print $2}'  >.66.txt
paste .55.txt .66.txt >.pci.txt
pci=`cat .22.txt`

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
aste aa.txt bb.txt .12.txt >.13.txt
fi
a=`cat .13.txt |grep -i "in use"`
if [ ! -n "$a" ]
then
         echo "" | grep -v "^$"
else

cat .13.txt |grep -i "in use" |awk '{print $1"    "$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8}' |awk  -F "In" '{print $1}' >.14.txt
fi

pcie=`lspci -v |grep -i sas |grep -B 1 $hba |grep -v "\--" |sed -n 1p |awk '{print $1}'`



pcie=`cat .14.txt |grep $pcie |awk '{$1="";print $0}'`


echo  "hba_info: $firmware*$hba_sn*$hba_model*$pcie"




elif [ "$hba" = SAS9300-8i -o  "$hba" = SAS9311-8i -o "$hba" = SAS9211-8i ]
then

	storcli /c$c /v0 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null >id.txt
				storcli /c$c /v0 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null >ID.txt
				storcli /c$c  /v0 show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"\t"$7"\t"$5""$6"     "$3}' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null >r.txt

raid_info=`paste id.txt r.txt`
				paste  id.txt ID.txt |awk '{print $1" "$2"   "$3}' >slot.txt
				storcli /c$c /v0 show all |grep RAID |awk '{print $2"\t"$9"TB""    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $1}' >3.txt
				storcli /c$c /v0 show all |grep RAID |awk '{print $2"\t"$9""$10"    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $2}' >4.txt
				storcli /c$c /v0 show all |grep RAID |awk '{print $2"\t"$9"TB""    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $3}' >5.txt
				num=`cat id.txt |wc -l`
				storcli /c$c /eall /sall show all |grep "Firmware Revision =" |sed -n 1,${num}p |awk -F "=" '{print $2}' 2>/dev/null >a.txt
				storcli /c$c /eall /sall show all |grep "Drive Temperature =" |sed -n 1,${num}p |awk -F "=" '{print $2}' |awk '{print $1}' 2>/dev/null >i.txt
				storcli /c$c show all |grep "Model =" |grep -v Yes |awk -F "=" '{print $2}' |awk '{print $1}' >1.txt
				storcli /c$c show all |grep "Model =" |grep -v Yes |awk -F "=" '{print $2}' |awk '{print $3"-"$4}' >2.txt
				storcli /c$c show all |grep "Firmware Version =" |grep -v Yes |awk -F "=" '{print $2}' >6.txt
				storcli /c$c show all |grep "On Board Memory Size"  |awk -F "=" '{print $2}' >7.txt
				#echo -e       "\033[36m Brand: Slot:ID:  Model:                 type:    Size:      status:   Revision:       cache/temp: \033[0m"  >bb.txt
				#echo -e       "\033[36m ------------------------------------------------------------------------------------------------ \033[0m"  >>bb.txt
				firmware=`storcli /c$c show all |grep "Firmware Version =" |grep -v Yes |awk -F "=" '{print $2}'`
				hba_sn=`storcli /c$c show  |grep 'Board Tracer Number =' |cut -f2 -d "="`
 				hba_model=`storcli /c$c show  |grep "Product Name =" |grep -v Yes  |awk -F "=" '{print $2}'`
				hba_level=`sas3ircu $c display |grep 'RAID level' |cut -f2 -d ':'`
				hba_status=`sas3ircu $c status |grep 'Volume state' |cut -f 2  -d :''`
				size=`sas3ircu $c display |grep 'Size (in MB)                            :' |cut -f 2 -d ":"`
if [ -z $size ]
then
echo "" | grep -v "^$"
else

hba_size=`expr $size / 1024 |awk '{print $1" GB"}' 2>/dev/null`
hba_dev=`lsscsi |grep 'Logical Volume' |awk '{print $NF}' |sed -n 1p |xargs 2>/dev/null`
echo
fi


lspci -v |grep -i sas |grep -iE '0.0|Subsystem:' >.33.txt
lspci -v |grep -i sas |grep -iE 0.0 |awk '{print $1}' >.22.txt
awk '!(NR%2)' .33.txt >.44.txt
paste .22.txt .44.txt  |awk '{print $1}' >.55.txt
paste .22.txt .44.txt  |awk -F '/' '{print $2}'  >.66.txt
paste .55.txt .66.txt >.pci.txt
pci=`cat .22.txt`

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

echo  "hba_info: $firmware*$hba_status*$hba_level*$hba_size*$hba_dev*$hba_sn*$hba_model*$pcie"


			else
 echo "" | grep -v "^$"

			fi

		fi


			rm -rf /.nfs/*.txt
rm -rf ./.*.txt ./*.txt

rm -rf storcli.log* storelibdebugit.txt* >/dev/null
rm -rf ../storcli.log* ../storelibdebugit.txt* >/dev/null

