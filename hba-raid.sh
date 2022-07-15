rpm -i ./storcli-007.1410.0000.0000-1.noarch.rpm  >/dev/null 2>&1
rpm -i ./storcli-007.1410.0000.0000-1.aarch64.rpm >/dev/null 2>&1

dpkg -i ./storcli_007.1410.0000.0000_all.deb >/dev/null 2>&1
dpkg -i ./storcli64_007.1410.0000.0000_arm64.deb >/dev/null 2>&1
scp -r  /opt/MegaRAID/storcli/storcli64 /usr/bin/storcli >/dev/null 2>&1
chmod 755 /opt/MegaRAID/storcli/storcli 2>/dev/null
scp -r /opt/MegaRAID/storcli/storcli /usr/bin/storcli >/dev/null 2>&1
cp -rf ./shell/sas3ircu /usr/bin >/dev/null 2>&1

cp -rf ./shell/sas2ircu /usr/bin >/dev/null 2>&1


sas=`sas3ircu 0 display |grep 'Controller type                         :'`
hba=`storcli show all |grep SAS |grep - |awk '{print $1" "$2}' |sed 's/AVAGOMegaRAIDSAS//g' |grep -E '9311|9300' |awk '{print $1}' |sed -n 1p`
hba1=`storcli show all |grep SAS |grep - |awk '{print $1" "$2}' |sed 's/AVAGOMegaRAIDSAS//g' |grep -E '9311|9300' |awk '{print $1}' |sed -n 2p`
sas1=`sas3ircu 1 display |grep 'Controller type                         :'`
#HBA卡一个
if [ -n "$sas" -o -n "$sas1" ] 
then

#V1 HBA卡
if [ -n "$sas" ]
then
#a=$1
aa=`sas3ircu 0 display |grep 'Enclosure # ' |cut -f2 -d ":"  |uniq |sort -n |awk '{print $1":"}' ` 
bb=`sas3ircu 0 display |grep 'Slot # ' |cut -f2 -d ":"  |sed 's/^/'${aa}'/' |awk '{print $1$2}' |xargs`
sas3ircu 0 create raid$a max $bb noprompt >/dev/null 2>&1
storcli /c$hba show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null  >id.txt
        storcli /c$hba  show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null  >ID.txt
storcli /c$hba  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null |sed 's/INTEL-SSDSC2KB240G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB480G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB960G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB[0-9A-Z]\+[GT]8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]8*/INTEL-S4610/g'| sed 's/SSDSC2KG[0-9A-Z]\+[GT]7./INTEL-S4600/g' >r.txt
  hba_level1=`sas3ircu 0 display |grep 'RAID level' |cut -f2 -d ':'`

raid_info=`paste id.txt r.txt`
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[1m" 
echo -e "\033[32;40m |                                             HBA Card 1                                      | \033[0m" 
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[0m" 
echo  "$raid_info"

                      firmware=`storcli /c$hba show all |grep "Firmware Version =" |grep -v Yes |awk -F "=" '{print $2}'`
                                hba_sn=`storcli /c$hba show  |grep 'Board Tracer Number =' |cut -f2 -d "="`
                                hba_model=`storcli /c$hba show  |grep "Product Name =" |grep -v Yes  |awk -F "=" '{print $2}'`
                                hba_level=`sas3ircu 0 display |grep 'RAID level' |cut -f2 -d ':'`
                                hba_status=`sas3ircu 0 status |grep 'Volume state' |cut -f 2  -d :''`
                                size=`sas3ircu 0 display |grep 'Size (in MB)                            :' |cut -f 2 -d ":"`
if [ -z $size ]
then
echo "" | grep -v "^$"
else

hba_size=`expr $size / 1024 |awk '{print $1" GB"}' 2>/dev/null`
hba_dev=`lsscsi |grep 'Logical Volume' |awk '{print $NF}' |sed -n 1p |xargs 2>/dev/null`
echo
fi
echo -e  "\033[36m ----------------------------------------------------------------------------------------- \033[0m"
echo  -e "\033[34m HBA卡信息 1:  $firmware *$hba_status * $hba_level * $hba_size * $hba_dev  * $hba_model  \033[0m"


else 
echo "" | grep -v "^$"
fi

#V1-1 HBA卡

if [ -n "$sas1" ]
then
#b=$2
aa=`sas3ircu 1 display |grep 'Enclosure # ' |cut -f2 -d ":"  |uniq |sort -n |awk '{print $1":"}' `
bb=`sas3ircu 1 display |grep 'Slot # ' |cut -f2 -d ":"  |sed 's/^/'${aa}'/' |awk '{print $1$2}' |xargs`
sas3ircu 1 create raid$b max $bb noprompt >/dev/null 2>&1
storcli /c$hba1 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null  >id.txt
        storcli /c$hba1  show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null  >ID.txt
storcli /c$hba1  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null |sed 's/INTEL-SSDSC2KB240G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB480G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB960G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB[0-9A-Z]\+[GT]8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]8*/INTEL-S4610/g'| sed 's/SSDSC2KG[0-9A-Z]\+[GT]7./INTEL-S4600/g' >r.txt
  hba_level2=`sas3ircu 1 display |grep 'RAID level' |cut -f2 -d ':'`

raid_info=`paste id.txt r.txt`
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[1m" 
echo -e "\033[32;40m |                                             HBA Card 2                                      | \033[0m" 
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[0m" 
echo  "$raid_info"

 firmware=`storcli /c$hba1 show all |grep "Firmware Version =" |grep -v Yes |awk -F "=" '{print $2}'`
                                hba_sn=`storcli /c$hba1 show  |grep 'Board Tracer Number =' |cut -f2 -d "="`
                                hba_model=`storcli /c$hba1 show  |grep "Product Name =" |grep -v Yes  |awk -F "=" '{print $2}'`
                                hba_level=`sas3ircu 1 display |grep 'RAID level' |cut -f2 -d ':'`
                                hba_status=`sas3ircu 1 status |grep 'Volume state' |cut -f 2  -d :''`
                                size=`sas3ircu 1 display |grep 'Size (in MB)                            :' |cut -f 2 -d ":"`
if [ -z $size ]
then
echo "" | grep -v "^$"
else

hba_size=`expr $size / 1024 |awk '{print $1" GB"}' 2>/dev/null`
hba_dev=`lsscsi |grep 'Logical Volume' |awk '{print $NF}' |sed -n 2p |xargs 2>/dev/null`
echo
fi
echo -e  "\033[36m ----------------------------------------------------------------------------------------- \033[0m"
echo  -e "\033[34m HBA卡信息 2:  $firmware *$hba_status * $hba_level * $hba_size * $hba_dev  * $hba_model  \033[0m"


else 
echo "" | grep -v "^$"
fi


# 创建RAID
echo
read -r -p "是否创建(Create)RAID? [Y/n] " input

case $input in

[yY][eE][sS]|[yY])




#创建V1 HBA卡
if [ -n "$sas" ]
then
#a=$1

echo
read -r -p "第1个HBA卡输入RAID级别，只能输入0,1,10,1E : " a
aa=`sas3ircu 0 display |grep 'Enclosure # ' |cut -f2 -d ":"  |uniq |sort -n |awk '{print $1":"}' `
bb=`sas3ircu 0 display |grep 'Slot # ' |cut -f2 -d ":"  |sed 's/^/'${aa}'/' |awk '{print $1$2}' |xargs`
sas3ircu 0 create raid$a max $bb noprompt >/dev/null 2>&1
storcli /c$hba show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null  >id.txt

        storcli /c$hba  show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null  >ID.txt
storcli /c$hba  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null |sed 's/INTEL-SSDSC2KB240G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB480G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB960G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB[0-9A-Z]\+[GT]8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]8*/INTEL-S4610/g'| sed 's/SSDSC2KG[0-9A-Z]\+[GT]7./INTEL-S4600/g' >r.txt
raid_info=`paste id.txt r.txt`

echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[1m" 
echo -e "\033[32;40m |                                             HBA Card 1                                      | \033[0m" 
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[0m" 
echo  "$raid_info"

                      firmware=`storcli /c$hba show all |grep "Firmware Version =" |grep -v Yes |awk -F "=" '{print $2}'`
                                hba_sn=`storcli /c$hba show  |grep 'Board Tracer Number =' |cut -f2 -d "="`
                                hba_model=`storcli /c$hba show  |grep "Product Name =" |grep -v Yes  |awk -F "=" '{print $2}'`
                                hba_level=`sas3ircu 0 display |grep 'RAID level' |cut -f2 -d ':'`
                                hba_status=`sas3ircu 0 status |grep 'Volume state' |cut -f 2  -d :''`
                                size=`sas3ircu 0 display |grep 'Size (in MB)                            :' |cut -f 2 -d ":"`
if [ -z $size ]
then
echo "" | grep -v "^$"
else

hba_size=`expr $size / 1024 |awk '{print $1" GB"}' 2>/dev/null`
hba_dev=`lsscsi |grep 'Logical Volume' |awk '{print $NF}' |sed -n 1p |xargs 2>/dev/null`
echo
fi
echo -e  "\033[36m ----------------------------------------------------------------------------------------- \033[0m"
echo  -e "\033[36m HBA卡信息 1:  $firmware *$hba_status * $hba_level * $hba_size * $hba_dev  * $hba_model  \033[0m"


else
echo "" | grep -v "^$"
fi

#创建V1-1 HBA卡

if [ -n "$sas1" ]
then
#b=$2
echo
read -r -p "第2个HBA卡输入RAID级别，只能输入0,1,10,1E : " b
aa=`sas3ircu 1 display |grep 'Enclosure # ' |cut -f2 -d ":"  |uniq |sort -n |awk '{print $1":"}' `
bb=`sas3ircu 1 display |grep 'Slot # ' |cut -f2 -d ":"  |sed 's/^/'${aa}'/' |awk '{print $1$2}' |xargs`
sas3ircu 1 create raid$b max $bb noprompt >/dev/null 2>&1
storcli /c$hba1 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null  >id.txt
        storcli /c$hba1  show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null  >ID.txt
storcli /c$hba1  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null |sed 's/INTEL-SSDSC2KB240G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB480G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB960G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB[0-9A-Z]\+[GT]8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]8*/INTEL-S4610/g'| sed 's/SSDSC2KG[0-9A-Z]\+[GT]7./INTEL-S4600/g' >r.txt
  hba_level2=`sas3ircu 1 display |grep 'RAID level' |cut -f2 -d ':'`

raid_info=`paste id.txt r.txt`
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[1m" 
echo -e "\033[32;40m |                                             HBA Card 2                                      | \033[0m" 
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[0m" 
echo  "$raid_info"

 firmware=`storcli /c$hba1 show all |grep "Firmware Version =" |grep -v Yes |awk -F "=" '{print $2}'`
                                hba_sn=`storcli /c$hba1 show  |grep 'Board Tracer Number =' |cut -f2 -d "="`
                                hba_model=`storcli /c$hba1 show  |grep "Product Name =" |grep -v Yes  |awk -F "=" '{print $2}'`
                                hba_level=`sas3ircu 1 display |grep 'RAID level' |cut -f2 -d ':'`
                                hba_status=`sas3ircu 1 status |grep 'Volume state' |cut -f 2  -d :''`
                                size=`sas3ircu 1 display |grep 'Size (in MB)                            :' |cut -f 2 -d ":"`
if [ -z $size ]
then
echo "" | grep -v "^$"
else

hba_size=`expr $size / 1024 |awk '{print $1" GB"}' 2>/dev/null`
hba_dev=`lsscsi |grep 'Logical Volume' |awk '{print $NF}' |sed -n 2p |xargs 2>/dev/null`
echo
fi
echo -e  "\033[36m ----------------------------------------------------------------------------------------- \033[0m"
echo  -e "\033[36m HBA卡信息 2:  $firmware *$hba_status * $hba_level * $hba_size * $hba_dev  * $hba_model  \033[0m"


else
echo "" | grep -v "^$"
fi




;;

[nN][oO]|[nN])

#echo "No"

;;

*)

echo "Invalid input..."

exit 1

;;

esac



#HBA卡硬盘定位
echo
read -r -p "是否开启HBA卡硬盘定位(Locate)? [Y/n] " input

case $input in

[yY][eE][sS]|[yY])


storcli /call show all |grep -E 'Drive /c.' |grep -E '[/ces0-9:]' |awk '{print $2}'  |sort -n |uniq >/dev/null 2>&1  >.1.txt
if [ -s .1.txt ]
then

echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[1m" 
echo -e "\033[32;40m |                                             HBA卡亮灯定位                                   | \033[0m" 
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[0m" 
count=` storcli show all |grep SAS |grep - |awk '{print $1" "$2}' |sed 's/AVAGOMegaRAIDSAS//g' |grep -E '9311|9300|9400' |awk '{print $1}'`

storcli /c$count show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null  >id.txt
#        storcli /c$count show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null  >ID.txt
 #storcli /c0  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null  >r.txt
storcli /c$count  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null |sed 's/INTEL-SSDSC2KB240G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB480G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB960G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB[0-9A-Z]\+[GT]8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]8*/INTEL-S4610/g'| sed 's/SSDSC2KG[0-9A-Z]\+[GT]7./INTEL-S4600/g' >r.txt

sn=`cat r.txt |cut -f1 |uniq |cut -f1 -d "-"` 
lsscsi |grep "$sn" |awk '{print $NF}' | uniq >.sn.txt
raid_info=`paste id.txt r.txt .sn.txt`
echo  "$raid_info"



for i in `cat .1.txt` ;do storcli $i start locate >/dev/null 2>&1 ;done
sleep 6
for i in `cat .1.txt` ;do storcli $i stop locate >/dev/null 2>&1  ;done
sleep 1
for i in `cat .sn.txt` ;do dd if=$i of=/dev/null bs=1M count=200 >/dev/null 2>&1 ;done

else
echo "" | grep -v "^$"
fi

rm -rf *.txt .*.txt

                        rm -rf /.nfs/*.txt


;;

[nN][oO]|[nN])

#echo "No"

;;

*)

echo "Invalid input..."

exit 1

;;

esac

# 清除RAID
echo
read -r -p "是否清除(clear)RAID? [Y/n] " input

case $input in

[yY][eE][sS]|[yY])

#echo "Yes"
sas3ircu 0 delete noprompt >/dev/null 2>&1
sas3ircu 1 delete noprompt >/dev/null 2>&1
sas3ircu 2 delete noprompt >/dev/null 2>&1

;;

[nN][oO]|[nN])

#echo "No"

;;

*)

echo "Invalid input..."

exGit 1

;;

esac



else 
echo "" | grep -v "^$"
fi

#有两个HBA卡时，或者有RAID和HBA卡

hba=`storcli show all |grep SAS |grep - |awk '{print $1" "$2}' |sed 's/AVAGOMegaRAIDSAS//g' |grep -E '9311|9300' |awk '{print $1}' |sed -n 1p`
hba1=`storcli show all |grep SAS |grep - |awk '{print $1" "$2}' |sed 's/AVAGOMegaRAIDSAS//g' |grep -E '9311|9300' |awk '{print $1}' |sed -n 2p`






sas2=`sas3ircu 2 display |grep 'Controller type                         :'`
if [ -n "$sas1" -a -n "$sas2" ]
then

#查看两个HBA卡信息

#d=$1
aa=`sas3ircu 1 display |grep 'Enclosure # ' |cut -f2 -d ":"  |uniq |sort -n |awk '{print $1":"}' `
bb=`sas3ircu 1 display |grep 'Slot # ' |cut -f2 -d ":"  |sed 's/^/'${aa}'/' |awk '{print $1$2}' |xargs`
storcli /c$hba1 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null  >id.txt
        storcli /c$hba1  show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null  >ID.txt
storcli /c$hba1  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null |sed 's/INTEL-SSDSC2KB240G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB480G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB960G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB[0-9A-Z]\+[GT]8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]8*/INTEL-S4610/g'| sed 's/SSDSC2KG[0-9A-Z]\+[GT]7./INTEL-S4600/g' >r.txt
  hba_level2=`sas3ircu 1 display |grep 'RAID level' |cut -f2 -d ':'`

raid_info=`paste id.txt r.txt`
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[1m" 
echo -e "\033[32;40m |                                             HBA Card 1                                      | \033[0m" 
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[0m" 
echo  "$raid_info"


 firmware=`storcli /c$hba show all |grep "Firmware Version =" |grep -v Yes |awk -F "=" '{print $2}'`
                                hba_sn=`storcli /c$hba show  |grep 'Board Tracer Number =' |cut -f2 -d "="`
                                hba_model=`storcli /c$hba show  |grep "Product Name =" |grep -v Yes  |awk -F "=" '{print $2}'`
                                hba_level=`sas3ircu 1 display |grep 'RAID level' |cut -f2 -d ':'`
                                hba_status=`sas3ircu 1 status |grep 'Volume state' |cut -f 2  -d :''`
                                size=`sas3ircu 1 display |grep 'Size (in MB)                            :' |cut -f 2 -d ":"`
if [ -z $size ]
then
echo "" | grep -v "^$"
else

hba_size=`expr $size / 1024 |awk '{print $1" GB"}' 2>/dev/null`
hba_dev=`lsscsi |grep 'Logical Volume' |awk '{print $NF}' |sed -n 1p |xargs 2>/dev/null`
echo
fi

echo  "hba_info1: $firmware *$hba_status * $hba_level * $hba_size * $hba_dev * $hba_sn * $hba_model"

#查看HBA卡2-2

if [ -n "$sas2" ]
then
#e=$2
aa=`sas3ircu 2 display |grep 'Enclosure # ' |cut -f2 -d ":"  |uniq |sort -n |awk '{print $1":"}' `
bb=`sas3ircu 2 display |grep 'Slot # ' |cut -f2 -d ":"  |sed 's/^/'${aa}'/' |awk '{print $1$2}' |xargs`
storcli /c$hba1 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null  >id.txt
        storcli /c$hba1  show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null  >ID.txt
storcli /c$hba1  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null |sed 's/INTEL-SSDSC2KB240G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB480G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB960G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB[0-9A-Z]\+[GT]8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]8*/INTEL-S4610/g'| sed 's/SSDSC2KG[0-9A-Z]\+[GT]7./INTEL-S4600/g' >r.txt
  hba_level2=`sas3ircu 2 display |grep 'RAID level' |cut -f2 -d ':'`

raid_info=`paste id.txt r.txt`
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[1m" 
echo -e "\033[32;40m |                                             HBA Card 2                                      | \033[0m" 
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[0m" 
echo  "$raid_info"


 firmware=`storcli /c$hba1 show all |grep "Firmware Version =" |grep -v Yes |awk -F "=" '{print $2}'`
                                hba_sn=`storcli /c$hba1 show  |grep 'Board Tracer Number =' |cut -f2 -d "="`
                                hba_model=`storcli /c$hba1 show  |grep "Product Name =" |grep -v Yes  |awk -F "=" '{print $2}'`
                                hba_level=`sas3ircu 2 display |grep 'RAID level' |cut -f2 -d ':'`
                                hba_status=`sas3ircu 2 status |grep 'Volume state' |cut -f 2  -d :''`
                                size=`sas3ircu 2 display |grep 'Size (in MB)                            :' |cut -f 2 -d ":"`
if [ -z $size ]
then
echo "" | grep -v "^$"
else

hba_size=`expr $size / 1024 |awk '{print $1" GB"}' 2>/dev/null`
hba_dev=`lsscsi |grep 'Logical Volume' |awk '{print $NF}' |sed -n 2p |xargs 2>/dev/null`
echo
fi

echo  "hba_info1: $firmware *$hba_status * $hba_level * $hba_size * $hba_dev * $hba_sn * $hba_model"
else
echo "" | grep -v "^$"

fi



# 创建RAID
echo
read -r -p "是否创建(Create)RAID? [Y/n] " input

case $input in

[yY][eE][sS]|[yY])

echo
read -r -p "第1个HBA卡输入RAID级别，只能输入0,1,10,1E : " d


#d=$1
aa=`sas3ircu 1 display |grep 'Enclosure # ' |cut -f2 -d ":"  |uniq |sort -n |awk '{print $1":"}' `
bb=`sas3ircu 1 display |grep 'Slot # ' |cut -f2 -d ":"  |sed 's/^/'${aa}'/' |awk '{print $1$2}' |xargs`
sas3ircu 1 create raid$d max $bb noprompt >/dev/null 2>&1
storcli /c$hba show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null  >id.txt
        storcli /c$hba  show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null  >ID.txt
storcli /c$hba  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null |sed 's/INTEL-SSDSC2KB240G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB480G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB960G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB[0-9A-Z]\+[GT]8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]8*/INTEL-S4610/g'| sed 's/SSDSC2KG[0-9A-Z]\+[GT]7./INTEL-S4600/g' >r.txt
  hba_level2=`sas3ircu 1 display |grep 'RAID level' |cut -f2 -d ':'`

raid_info=`paste id.txt r.txt`
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[1m" 
echo -e "\033[32;40m |                                             HBA Card 1                                      | \033[0m" 
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[0m" 
echo  "$raid_info"
 firmware=`storcli /c$hba show all |grep "Firmware Version =" |grep -v Yes |awk -F "=" '{print $2}'`
                                hba_sn=`storcli /c$hba show  |grep 'Board Tracer Number =' |cut -f2 -d "="`
                                hba_model=`storcli /c$hba show  |grep "Product Name =" |grep -v Yes  |awk -F "=" '{print $2}'`
                                hba_level=`sas3ircu 1 display |grep 'RAID level' |cut -f2 -d ':'`
                                hba_status=`sas3ircu 1 status |grep 'Volume state' |cut -f 2  -d :''`
                                size=`sas3ircu 1 display |grep 'Size (in MB)                            :' |cut -f 2 -d ":"`
if [ -z $size ]
then
echo "" | grep -v "^$"
else

hba_size=`expr $size / 1024 |awk '{print $1" GB"}' 2>/dev/null`
hba_dev=`lsscsi |grep 'Logical Volume' |awk '{print $NF}' |sed -n 1p |xargs 2>/dev/null`
echo
fi

echo  "hba_info1: $firmware *$hba_status * $hba_level * $hba_size * $hba_dev * $hba_sn * $hba_model"

#HBA卡2-2

if [ -n "$sas2" ]
then
#e=$2
echo
read -r -p "第1个HBA卡输入RAID级别，只能输入0,1,10,1E : " e


aa=`sas3ircu 2 display |grep 'Enclosure # ' |cut -f2 -d ":"  |uniq |sort -n |awk '{print $1":"}' `
bb=`sas3ircu 2 display |grep 'Slot # ' |cut -f2 -d ":"  |sed 's/^/'${aa}'/' |awk '{print $1$2}' |xargs`
sas3ircu 2 create raid$e max $bb noprompt >/dev/null 2>&1
storcli /c$hba1 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null  >id.txt
        storcli /c$hba1  show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null  >ID.txt
storcli /c$hba1  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null |sed 's/INTEL-SSDSC2KB240G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB480G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB960G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB[0-9A-Z]\+[GT]8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]8*/INTEL-S4610/g'| sed 's/SSDSC2KG[0-9A-Z]\+[GT]7./INTEL-S4600/g' >r.txt
  hba_level3=`sas3ircu 2 display |grep 'RAID level' |cut -f2 -d ':'`

raid_info=`paste id.txt r.txt`
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[1m" 
echo -e "\033[32;40m |                                             HBA Card 2                                      | \033[0m" 
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[0m" 
echo  "$raid_info"

 firmware=`storcli /c$hba1 show all |grep "Firmware Version =" |grep -v Yes |awk -F "=" '{print $2}'`
                                hba_sn=`storcli /c$hba1 show  |grep 'Board Tracer Number =' |cut -f2 -d "="`
                                hba_model=`storcli /c$hba1 show  |grep "Product Name =" |grep -v Yes  |awk -F "=" '{print $2}'`
                                hba_level=`sas3ircu 2 display |grep 'RAID level' |cut -f2 -d ':'`
                                hba_status=`sas3ircu 2 status |grep 'Volume state' |cut -f 2  -d :''`
                                size=`sas3ircu 2 display |grep 'Size (in MB)                            :' |cut -f 2 -d ":"`
if [ -z $size ]
then
echo "" | grep -v "^$"
else

hba_size=`expr $size / 1024 |awk '{print $1" GB"}' 2>/dev/null`
hba_dev=`lsscsi |grep 'Logical Volume' |awk '{print $NF}' |sed -n 2p |xargs 2>/dev/null`
echo
fi

echo  "hba_info1: $firmware *$hba_status * $hba_level * $hba_size * $hba_dev * $hba_sn * $hba_model"
else 
echo "" | grep -v "^$"

fi

;;

[nN][oO]|[nN])

#echo "No"

;;

*)

echo "Invalid input..."

exit 1

;;

esac




#HBA卡硬盘定位
echo
read -r -p "是否开启HBA卡硬盘定位(Locate)? [Y/n] " input

case $input in

[yY][eE][sS]|[yY])


storcli /call show all |grep -E 'Drive /c.' |grep -E '[/ces0-9:]' |awk '{print $2}'  |sort -n |uniq >/dev/null 2>&1  >.1.txt
if [ -s .1.txt ]
then
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[1m" 
echo -e "\033[32;40m |                                             HBA卡亮灯定位                                   | \033[0m" 
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[0m" 
count=` storcli show all |grep SAS |grep - |awk '{print $1" "$2}' |sed 's/AVAGOMegaRAIDSAS//g' |grep -E '9311|9300|9400' |awk '{print $1}'`

storcli /c$count show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null  >id.txt
        storcli /c$count show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null  >ID.txt
 #storcli /c0  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null  >r.txt
storcli /c$count  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null |sed 's/INTEL-SSDSC2KB240G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB480G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB960G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB[0-9A-Z]\+[GT]8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]8*/INTEL-S4610/g'| sed 's/SSDSC2KG[0-9A-Z]\+[GT]7./INTEL-S4600/g' >r.txt

sn=`cat r.txt |cut -f1 |uniq |cut -f1 -d "-"`
lsscsi |grep "$sn" |awk '{print $NF}' | uniq >.sn.txt
raid_info=`paste id.txt r.txt .sn.txt`
echo  "$raid_info"


#raid_info=`paste id.txt r.txt`
#echo  "$raid_info"



for i in `cat .1.txt` ;do storcli $i start locate >/dev/null 2>&1 ;done
sleep 8
for i in `cat .1.txt` ;do storcli $i stop locate >/dev/null 2>&1  ;done
for i in `cat .sn.txt` ;do dd if=$i of=/dev/null bs=1M count=200 >/dev/null 2>&1 ;done


else
echo "" | grep -v "^$"
fi

rm -rf *.txt .*.txt

                        rm -rf /.nfs/*.txt


;;

[nN][oO]|[nN])

#echo "No"

;;

*)

echo "Invalid input..."

exit 1

;;

esac


#清除RAID
read -r -p "是否清除RAID? [Y/n] " input

case $input in

[yY][eE][sS]|[yY])

sas3ircu 0 delete noprompt >/dev/null 2>&1
sas3ircu 1 delete noprompt >/dev/null 2>&1
sas3ircu 2 delete noprompt >/dev/null 2>&1

;;

[nN][oO]|[nN])

#echo "No"

;;

*)

echo "Invalid input..."

exit 1

;;

esac


rm -rf *.txt .*.txt

                        rm -rf /.nfs/*.txt






else
echo "" | grep -v "^$"
fi

