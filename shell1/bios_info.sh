LANG=en_US.UTF-8 >/dev/null

a=`dmidecode -t 0 |grep "Version:" |uniq`
b=`dmidecode -t 0 |grep "Release Date:" |cut -f 2 -d ":" |uniq`
d=` lspci | grep -i contro |grep -i 'SATA controller:' |grep -o  '\[.*\]' |cut -f1 -d " " |tr -d '[' |uniq |sed -n 1p`
ban=`cat /etc/redhat-release 2>/dev/null  || cat /etc/kylin-release 2>/dev/null`
LANG="zh_CN.UTF-8"
if [ -z "$ban" ]
then
c=` hwclock |cut -f1 -d "."`
else
c=`hwclock |cut -f1  -d "-" |uniq |sed 's/CST//g' |sed 's/时/:/g;s/分/:/g;s/秒//g'`
fi
echo  "$a*$d*$b*$c"
