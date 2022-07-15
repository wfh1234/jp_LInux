a=`dmidecode -t 2 |grep "Manufacturer:" |uniq`
b=`dmidecode -t 2 |grep "Product Name:" |uniq`
c=`dmidecode -t 2 |grep "Serial Number:" | uniq`

echo  "$a*$b*$c"
