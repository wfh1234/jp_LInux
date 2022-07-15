storcli /call show all |grep -E 'Drive /c.' |grep -E '[/ces0-9:]' |awk '{print $2}'  |sort -n |uniq >/dev/null 2>&1  >.1.txt
if [ -s .1.txt ]
then
for i in `cat .1.txt` ;do storcli $i start locate >/dev/null 2>&1 ;done 
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[1m" 
echo -e "\033[32;40m |                                             HBA卡亮灯定位                                   | \033[0m" 
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[0m" 
storcli /call show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null  >id.txt
        storcli /call  show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null  >ID.txt
 #storcli /c0  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null  >r.txt
storcli /call  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null |sed 's/INTEL-SSDSC2KB240G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB480G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB960G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB[0-9A-Z]\+[GT]8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]8*/INTEL-S4610/g'| sed 's/SSDSC2KG[0-9A-Z]\+[GT]7./INTEL-S4600/g' >r.txt

raid_info=`paste id.txt r.txt`
echo  "$raid_info"



sleep 15
for i in `cat .1.txt` ;do storcli $i stop locate >/dev/null 2>&1  ;done

else 
echo "" | grep -v "^$"
fi

rm -rf *.txt .*.txt

			rm -rf /.nfs/*.txt


