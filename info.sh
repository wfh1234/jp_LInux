rpm -i ./shell/storcli-007.1410.0000.0000-1.noarch.rpm  >/dev/null 2>&1
rpm -i ./shell/storcli-007.1410.0000.0000-1.aarch64.rpm >/dev/null 2>&1

dpkg -i ./shell/storcli_007.1410.0000.0000_all.deb >/dev/null 2>&1
dpkg -i ./shell/storcli64_007.1410.0000.0000_arm64.deb >/dev/null 2>&1
scp -r  /opt/MegaRAID/storcli/storcli64 /usr/bin/storcli >/dev/null 2>&1
chmod 755 /opt/MegaRAID/storcli/storcli 2>/dev/null
scp -r /opt/MegaRAID/storcli/storcli /usr/bin/storcli >/dev/null 2>&1
 hba=`storcli /c0 show  |grep 'Product Name' |awk -F "=" '{print $2}' |awk '{print $NF}'`


if [ "$hba" = SAS9300-8i -o  "$hba" = SAS9311-8i -o "$hba" = SAS9211-8i -o "$hba" = 9400-8i ]
then
 echo "" | grep -v "^$"

else

c=`storcli /c0 /v0 show all  |grep Onln |grep -E 'HDD|SATA SSD'`
if [ -n "$c" ]
then 
storcli /c0/v0 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null  >id.txt
        storcli /c0/v0  show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null  >ID.txt
 #storcli /c0  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null  >r.txt
storcli /c0/v0  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null |sed 's/INTEL-SSDSC2KB240G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB480G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB960G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB[0-9A-Z]\+[GT]8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]8*/INTEL-S4610/g'| sed 's/SSDSC2KG[0-9A-Z]\+[GT]7./INTEL-S4600/g' >r.txt
raid_status1=`storcli /c0 /v0 show all |grep RAID |awk '{print $2"\t"$9"TB""    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $3}'`
raid_level1=`storcli /c0 /v0 show all |grep RAID |awk '{print $2"\t"$9"TB""    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $1}'`
raid_size1=`storcli /c0 /v0 show all |grep RAID |awk '{print $2"\t"$9""$10"    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $2}'`
a=`storcli /c0 show all |grep "Model =" |grep -v Yes |awk     -F "=" '{print $2}' |awk '{print $3"-"$4}' |awk -F '-' '{print $2"-"$3}'`
raid_dev1=`lsscsi |grep $a |awk '{print $NF}' |sed -n 1p`
firmware=`storcli /c0 show all |grep "Firmware Version =" |grep -v Yes |awk -F "=" '{print $2}'`
raid_model=`storcli /c0 show all |grep "Model =" |grep -v Yes |awk -F "=" '{print $2}' |awk '{print $3"-"$4}'`
raid_cache=`storcli /c0 show all |grep "On Board Memory Size"  |awk -F "=" '{print $2}'`


raid_info=`paste id.txt r.txt`
echo  "$raid_info"

echo -e  "\033[36m ----------------------------------------------------------------------------------------- \033[0m"
echo  -e "\033[36m 硬盘组VD0: $raid_status1 * $raid_level1 * $raid_size1 * $raid_dev1 * $firmware * $raid_model * $raid_cache  \033[0m"
rm -rf ./.*.txt ./*.txt
else
 echo -e "\033[31m "无RAID，需要重新创建RAID" \033[0m"
./shell/raid_info2.sh 2>/dev/null 
fi



c=`storcli /c0 /v1 show all  |grep Onln |grep -E 'HDD|SATA SSD'`
if [ -n "$c" ]
then 
storcli /c0/v1 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null  >id.txt
        storcli /c0/v1  show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null  >ID.txt
 #storcli /c0  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null  >r.txt
storcli /c0/v1  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null |sed 's/INTEL-SSDSC2KB240G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB480G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB960G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB[0-9A-Z]\+[GT]8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]8*/INTEL-S4610/g'| sed 's/SSDSC2KG[0-9A-Z]\+[GT]7./INTEL-S4600/g' >r.txt
raid_status1=`storcli /c0 /v1 show all |grep RAID |awk '{print $2"\t"$9"TB""    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $3}'`
raid_level1=`storcli /c0 /v1 show all |grep RAID |awk '{print $2"\t"$9"TB""    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $1}'`
raid_size1=`storcli /c0 /v1 show all |grep RAID |awk '{print $2"\t"$9""$10"    "$3}' |sed 's/Optl/Optimal/g' |awk '{print $2}'`
a=`storcli /c0 show all |grep "Model =" |grep -v Yes |awk     -F "=" '{print $2}' |awk '{print $3"-"$4}' |awk -F '-' '{print $2"-"$3}'`
raid_dev1=`lsscsi |grep $a |awk '{print $NF}' |sed -n 2p`
      
raid_info=`paste id.txt r.txt`
echo  "$raid_info"
    
echo -e  "\033[36m ---------------------------------------------------------------------------------------- \033[0m"
echo  -e "\033[36m 硬盘组VD1: $raid_status1 * $raid_level1 * $raid_size1 * $raid_dev1 * $firmware * $raid_model * $raid_cache  \033[0m"
#echo  -e "\033[36m 硬盘组VD1: $raid_status1 * $raid_level1 * $raid_size1 * $raid_dev1 \033[0m"
rm -rf ./.*.txt ./*.txt
fi


                        fi

