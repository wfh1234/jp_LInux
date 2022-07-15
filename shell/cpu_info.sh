LANG=en_US.UTF-8 >/dev/null
cpu_version1=`dmidecode -t 4 |grep "Version:"  |cut -c 10-60 |sed -n  1p`
cpu_version2=`dmidecode -t 4 |grep "Version:"  |cut -c 10-60 |sed -n  2p`
cpu_version3=`dmidecode -t 4 |grep "Version:"  |cut -c 10-60 |sed -n  3p`
cpu_version4=`dmidecode -t 4 |grep "Version:"  |cut -c 10-60 |sed -n  4p`
core1=`dmidecode -t 4 |grep "Core Count:" |awk '{print $3}' |sed -n 1p`
core2=`dmidecode -t 4 |grep "Core Count:" |awk '{print $3}' |sed -n 2p`
core3=`dmidecode -t 4 |grep "Core Count:" |awk '{print $3}' |sed -n 3p`
core4=`dmidecode -t 4 |grep "Core Count:" |awk '{print $3}' |sed -n 4p`
LGA1=`dmidecode -t 4 |grep Upgrade: |cut -f 3  -d " " |sed -n 1p |sed 's/OF/3647/g'`
aa=`dmidecode -t 4 |grep "Version:"  |cut -c 10-60 |sed -n  1p  |grep 'E-2|W-2'`
if [ -z "$LGA1" ]
then
LGA1=`dmidecode -t 4 |grep "Version:"  |cut -c 10-60 |sed -n  1p  |grep E3 |awk '{print $4}' |sed 's/E3-12[0-9]\+/LGA 1151/g'`
LGA2=`dmidecode -t 4 |grep "Version:"  |cut -c 10-60 |sed -n  2p  |grep E3 |awk '{print $4}' |sed 's/E-2[0-9A-Z]\+/LGA 1151/g'`
LGA3=`dmidecode -t 4 |grep "Version:"  |cut -c 10-60 |sed -n  3p  |grep E3 |awk '{print $4}' |sed 's/E-2[0-9A-Z]\+/LGA 1151/g'`
LGA4=`dmidecode -t 4 |grep "Version:"  |cut -c 10-60 |sed -n  4p  |grep E3 |awk '{print $4}' |sed 's/E-2[0-9A-Z]\+/LGA 1151/g'`
elif [ -n "$aa" ] 
then
LGA1=`dmidecode -t 4 |grep "Version:"  |cut -c 10-60 |sed -n  1p  |grep -E 'E-2|W-2' |awk '{print $3}' |sed 's/E-2[0-9A-Z]\+/LGA 1151/g' |sed 's/W-2[0-9A-Z]\+/LGA 2066/g'`
LGA2=`dmidecode -t 4 |grep "Version:"  |cut -c 10-60 |sed -n  2p  |grep -E 'E-2|W-2' |awk '{print $3}' |sed 's/E-2[0-9A-Z]\+/LGA 1151/g' |sed 's/W-2[0-9A-Z]\+/LGA 2066/g'`
LGA3=`dmidecode -t 4 |grep "Version:"  |cut -c 10-60 |sed -n  3p  |grep -E 'E-2|W-2' |awk '{print $3}' |sed 's/E-2[0-9A-Z]\+/LGA 1151/g' |sed 's/W-2[0-9A-Z]\+/LGA 2066/g'`
LGA4=`dmidecode -t 4 |grep "Version:"  |cut -c 10-60 |sed -n  4p  |grep -E 'E-2|W-2' |awk '{print $3}' |sed 's/E-2[0-9A-Z]\+/LGA 1151/g' |sed 's/W-2[0-9A-Z]\+/LGA 2066/g'`
else


LGA1=`dmidecode -t 4 |grep Upgrade: |cut -f 3  -d " " |sed -n 1p |sed 's/OF/3647/g'`
LGA2=`dmidecode -t 4 |grep Upgrade: |cut -f 3  -d " " |sed -n 2p |sed 's/OF/3647/g'`
LGA3=`dmidecode -t 4 |grep Upgrade: |cut -f 3  -d " " |sed -n 3p |sed 's/OF/3647/g'`
LGA4=`dmidecode -t 4 |grep Upgrade: |cut -f 3  -d " " |sed -n 4p |sed 's/OF/3647/g'`

fi
a=`lscpu |grep "Socket(s): "  |cut -f2 -d ":"`
if [ $a = 2 ]
then
echo   "cpu_info: cpu1*$cpu_version1*$core1*$LGA1"
echo   "cpu_info: cpu2*$cpu_version2*$core2*$LGA2"
elif [ $a = 4 ]
then
echo   "cpu_info: cpu1*$cpu_version1*$core1*$LGA1"
echo   "cpu_info: cpu2*$cpu_version2*$core2*$LGA2"
echo   "cpu_info: cpu3*$cpu_version3*$core3*$LGA3"
echo   "cpu_info: cpu4*$cpu_version4*$core4*$LGA4"
else
echo   "cpu_info: cpu1*$cpu_version1*$core1*$LGA1"
fi
