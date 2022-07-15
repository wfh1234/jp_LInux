echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[1m" 
echo -e "\033[32;40m |                                             RAID                                            | \033[0m" 
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[0m" 

#./shell/raid_info2.sh 2>/dev/null
echo 
./info.sh 2>/dev/null


hba=`storcli /c0 show  |grep 'Product Name' |awk -F "=" '{print $2}' |awk '{print $NF}'`
if [ "$hba" = SAS9300-8i -o  "$hba" = SAS9311-8i -o "$hba" = SAS9211-8i -o "$hba" = 9400-8i ]
then
 echo "" | grep -v "^$"

else
echo -e ""
#第一次创建RAID用于掉盘
read -r -p "是否创建(Create)RAID? [Y/n] " input

case $input in

[yY][eE][sS]|[yY])

read -r -p "输入RAID级别，只能输入0,1,10,5,50,60 : " a
read -r -p "输入RAID容量，以GB、TB为单位，如果全部输入all : " b
read -r -p "输入物理硬盘序号，列如0-3 or 0,1,2,3 or 0,2 : " c
read -r -p "输入RAID组数，raid0,1,5,6输入0即可，RAID10,50,60输入对应盘组数量 : " d
#storcli /c0 /v0 del force >/dev/null 2>&1
storcli /c0 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}'  >.1.txt

storcli /c0 add vd type=raid$a  size=$b  drives=252:$c  awb PDperArray=$d >/dev/null

hba=`storcli /c0 show  |grep 'Product Name' |awk -F "=" '{print $2}' |awk '{print $NF}'`


if [ "$hba" = SAS9300-8i -o  "$hba" = SAS9311-8i -o "$hba" = SAS9211-8i -o "$hba" = 9400-8i ]
then
 echo "" | grep -v "^$"

else

storcli /c0 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null  >id.txt
        storcli /c0  show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null  >ID.txt
 #storcli /c0  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null  >r.txt
storcli /c0  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null |sed 's/INTEL-SSDSC2KB240G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB480G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB960G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB[0-9A-Z]\+[GT]8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]8*/INTEL-S4610/g'| sed 's/SSDSC2KG[0-9A-Z]\+[GT]7./INTEL-S4600/g' >r.txt

raid_info=`paste id.txt r.txt`
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[1m" 
echo -e "\033[32;40m |                                             RAID                                            | \033[0m" 
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[0m" 
#echo  "$raid_info"
rm -rf ./.*.txt ./*.txt
./info.sh 2>/dev/null

                        fi

rm -rf storcli.log* storelibdebugit.txt* >/dev/null
rm -rf ../storcli.log* ../storelibdebugit.txt* >/dev/null
rm -rf ./.*.txt ./*.txt

;;

*)


#echo "No"

;;

*)

echo "Invalid input..."

exit 1

;;

esac


#RAID后物理磁盘定位
echo 
read -r -p "是否物理磁盘定位(locate)?  [Y/n] " input

case $input in

[yY][eE][sS]|[yY])
s=`storcli /c0/eall/sall show all |grep -E 'Drive /c.' |grep -E '[/ces0-9:]' |awk '{print $2}'  |sort -n |uniq`
for i in $s ;do storcli $i start locate  >/dev/null 2>&1 ;done
sleep 6
for i in $s ;do storcli $i stop locate  >/dev/null 2>&1 ;done
for i in $s ;do storcli $i start locate  >/dev/null 2>&1  ; sleep 1  ;done

for i in $s ;do storcli $i stop locate  >/dev/null 2>&1 ;done
;;

*)


#echo "No"

;;

*)

echo "Invalid input..."

exit 1

;;

esac

#RAID掉盘、告警

echo 
s=`storcli /c0/eall/sall show all |grep -E 'Drive /c.' |grep -E '[/ces0-9:]' |awk '{print $2}'  |sort -n |uniq`
read -r -p "RAID告警、是否掉盘(offline) [Y/n] " input

case $input in

[yY][eE][sS]|[yY])  

read -r -p "把拔掉的硬盘插回去，再删除RAID组,清除拨盘的UB状态，清除外部配置(foreign)  : " e
sleep 1
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[1m" 
echo -e "\033[32;40m |                                             RAID                                            | \033[0m" 
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[0m" 

storcli /c0 /v$e del force >/dev/null 2>&1
num=1
while [ $num -le 20 ]
do

info=`storcli /c0 show all   |grep -E 'HDD|SATA SSD' |grep - |grep UBad` 
if [ -n "$info" ]
then
./info.sh 2>/dev/null
 for i in $s ;do storcli $i set good force  ;done  >/dev/null 2>&1
storcli /c0 /fall del >/dev/null 2>&1
else
sleep 1
fi
num=$(( $num + 1 ))
done




;;

*)


#echo "No"

;;

*)

echo "Invalid input..."

exit 1

;;

esac

#第二次创建RAID
echo 
read -r -p "是否创建(Create)RAID? [Y/n] " input

case $input in

[yY][eE][sS]|[yY])

read -r -p "输入RAID级别，只能输入0,1,10,5,50,60 : " a
read -r -p "输入RAID容量，以GB、TB为单位，如果全部输入all : " b
read -r -p "输入物理硬盘序号，列如0-3 or 0,1,2,3 or 0,2 : " c
read -r -p "输入RAID组数，raid0,1,5,6输入0即可，RAID10,50,60输入对应盘组数量 : " d
#storcli /c0 /v0 del force >/dev/null 2>&1
storcli /c0 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}'  >.1.txt

storcli /c0 add vd type=raid$a  size=$b  drives=252:$c  awb PDperArray=$d >/dev/null
# 数据
hba=`storcli /c0 show  |grep 'Product Name' |awk -F "=" '{print $2}' |awk '{print $NF}'`


if [ "$hba" = SAS9300-8i -o  "$hba" = SAS9311-8i -o "$hba" = SAS9211-8i -o "$hba" = 9400-8i ]
then
 echo "" | grep -v "^$"

else

storcli /c0 show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $1}' |cut -f 2 -d ":" 2>/dev/null  >id.txt
        storcli /c0  show all   |grep -E 'HDD|SATA SSD' |grep - |awk '{print $2}' 2>/dev/null  >ID.txt
 #storcli /c0  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null  >r.txt
storcli /c0  show all  | grep -E 'HDD|SATA SSD' |grep - |awk '{print $12"-"$13"\t"$7"\t"$5""$6"     "$3}'  |sed 's/-U//g' |sed 's/Onln/Online/g' |sed 's/Offln/Offline/g' 2>/dev/null |sed 's/INTEL-SSDSC2KB240G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB480G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB960G8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KB[0-9A-Z]\+[GT]8/INTEL-S4510/g' |sed 's/INTEL-SSDSC2KG[0-9A-Z]\+[GT]8*/INTEL-S4610/g'| sed 's/SSDSC2KG[0-9A-Z]\+[GT]7./INTEL-S4600/g' >r.txt

raid_info=`paste id.txt r.txt`
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[1m" 
echo -e "\033[32;40m |                                             RAID                                            | \033[0m" 
echo -e "\033[32;40m ----------------------------------------------------------------------------------------------- \033[0m" 
#echo  "$raid_info"
rm -rf ./.*.txt ./*.txt
./info.sh 2>/dev/null

                        fi

rm -rf storcli.log* storelibdebugit.txt* >/dev/null
rm -rf ../storcli.log* ../storelibdebugit.txt* >/dev/null
rm -rf ./.*.txt ./*.txt


;;

*)


#echo "No"

;;

*)

echo "Invalid input..."

exit 1

;;

esac
#询问是否删除RAID
echo 
read -r -p "是否删除(Clear)RAID? [Y/n] " input

case $input in

[yY][eE][sS]|[yY])
read -r -p "删除RAID组VD0:  " d
read -r -p "删除RAID组VD1:  " e

storcli /c0 /v$d  del force >/dev/null 2>&1
storcli /c0 /v$e  del force >/dev/null 2>&1

;;

*)
#echo "No"

;;

*)

echo "Invalid input..."

exit 1

;;

esac




fi
