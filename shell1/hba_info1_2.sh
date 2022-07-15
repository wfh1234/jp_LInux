#! /bin/bash
rpm -i ./storcli-007.1410.0000.0000-1.noarch.rpm  >/dev/null 2>&1
rpm -i ./storcli-007.1410.0000.0000-1.aarch64.rpm >/dev/null 2>&1

dpkg -i ./storcli_007.1410.0000.0000_all.deb >/dev/null 2>&1
dpkg -i ./storcli64_007.1410.0000.0000_arm64.deb >/dev/null 2>&1
scp -r  /opt/MegaRAID/storcli/storcli64 /usr/bin/storcli >/dev/null 2>&1
chmod 755 /opt/MegaRAID/storcli/storcli 2>/dev/null
scp -r /opt/MegaRAID/storcli/storcli /usr/bin/storcli >/dev/null 2>&1

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


 hba=`storcli /c$c show  |grep 'Product Name' |awk -F "=" '{print $2}' |awk '{print $NF}'`
if [ "$hba" = SAS9300-8i -o  "$hba" = SAS9311-8i  -o "$hba" = 9400-8i ]
then


storcli /c$c show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null  >id.txt
        storcli /c$c  show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null  >ID.txt
 #storcli /c0  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null  >r.txt
storcli /c$c  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null |sed 's/INTEL-SSDSC2KB240G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB480G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB960G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB[0-9A-Z]\+[GT]8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]8*/INTEL-S4610/g'| sed 's/SSDSC2KG[0-9A-Z]\+[GT]7./INTEL-S4600/g' >r.txt

raid_info=`paste id.txt r.txt`
echo  "$raid_info"
rm -rf ./.*.txt ./*.txt
else
 echo "" | grep -v "^$"

                        fi

