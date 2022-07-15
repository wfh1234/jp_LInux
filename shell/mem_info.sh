dmidecode -t 17 |grep Manufacturer:  |cut -f 2 -d ":" |grep -vE 'NoModule|Unknown|NO DIMM|Not Specified|Empty' >.mem_Manufacturer.txt
dmidecode -t 17|grep -A5 'Memory Device'|grep Size |grep -v Range |cut -f 2 -d ":" |awk '{print ""$1""$2}' >.mem_size.txt
dmidecode -t 17 |grep Locator: |grep -v "Bank Locator" |cut -f 2 -d ":"  >.mem_Locator.txt
dmidecode -t 17|grep -A16 'Memory Device' |grep 'Speed' |cut -f 2 -d ":" |grep -vE 'NoModule|Unknown|NO DIMM|Not Specified|Empty' |awk '{print $1""$2}' >.mem_speed.txt
dmidecode -t 17 |grep Type: |cut -f 2 -d ":" >.mem_type.txt
dmidecode -t memory |grep  "Part Number:"  |cut -f2 -d ":" |grep -vE 'NoModule|Unknown|NO DIMM|Not Specified|Empty' >.pn.txt
a=`cat .pn.txt |grep -E M393A |sed -n 1p`
b=`cat .pn.txt |grep -E M391A |sed -n 1p`
c=`cat .pn.txt |grep -E M386A |sed -n 1p`
d=`dmidecode -t memory | grep -viE None |grep -E 'Type Detail:|Total Width:|Data Width:' |grep -vi Unknown |sort -n |uniq |awk '{print $3}' |xargs`
e=`echo "64 72 Synchronous"`
f=`echo "72 72 Synchronous"`
#
if [ -n "$a" ]
then
paste -d "*"   .mem_Locator.txt .mem_size.txt  .mem_type.txt |grep -vE 'NoModule|Unknown|NO DIMM|Not Specified|Empty' |awk '{print $0"-RECC"}' >.mem-1.txt
elif [ "$d" == "$e" ]
then
paste  -d "*"  .mem_Locator.txt   .mem_size.txt  .mem_type.txt |grep -vE 'NoModule|Unknown|NO DIMM|Not Specified|Empty' |awk '{print $0"-ECC"}' >.mem-1.txt
elif [ "$d" == "$f" ]
then
paste -d "*"   .mem_Locator.txt .mem_size.txt  .mem_type.txt |grep -vE 'NoModule|Unknown|NO DIMM|Not Specified|Empty' |awk '{print $0"-RECC"}' >.mem-1.txt
else 
paste  -d "*"  .mem_Locator.txt   .mem_size.txt  .mem_type.txt |grep -vE 'NoModule|Unknown|NO DIMM|Not Specified|Empty'| awk '{print $0"-PC"}' >.mem-1.txt
fi
#第2
if [ -n "$b" ]
then
paste -d "*"   .mem_Locator.txt .mem_size.txt  .mem_type.txt |grep -vE 'NoModule|Unknown|NO DIMM|Not Specified|Empty' |awk '{print $0"-RECC"}' >.mem-1.txt
elif [ "$d" == "$e" ]
then
paste  -d "*"  .mem_Locator.txt   .mem_size.txt  .mem_type.txt |grep -vE 'NoModule|Unknown|NO DIMM|Not Specified|Empty' |awk '{print $0"-ECC"}' >.mem-1.txt
elif [ "$d" == "$f" ]
then
paste -d "*"   .mem_Locator.txt .mem_size.txt  .mem_type.txt |grep -vE 'NoModule|Unknown|NO DIMM|Not Specified|Empty' |awk '{print $0"-RECC"}' >.mem-1.txt
else
paste  -d "*"  .mem_Locator.txt   .mem_size.txt  .mem_type.txt |grep -vE 'NoModule|Unknown|NO DIMM|Not Specified|Empty'| awk '{print $0"-PC"}' >.mem-1.txt
fi



#第三
if [ -n "$c" ]
then
paste -d "*"   .mem_Locator.txt .mem_size.txt  .mem_type.txt |grep -vE 'NoModule|Unknown|NO DIMM|Not Specified|Empty' |awk '{print $0"-RECC"}' >.mem-1.txt
elif [ "$d" == "$e" ]
then
paste  -d "*"  .mem_Locator.txt   .mem_size.txt  .mem_type.txt |grep -vE 'NoModule|Unknown|NO DIMM|Not Specified|Empty' |awk '{print $0"-ECC"}' >.mem-1.txt
elif [ "$d" == "$f" ]
then
paste -d "*"   .mem_Locator.txt .mem_size.txt  .mem_type.txt |grep -vE 'NoModule|Unknown|NO DIMM|Not Specified|Empty' |awk '{print $0"-RECC"}' >.mem-1.txt
else
paste  -d "*"  .mem_Locator.txt   .mem_size.txt  .mem_type.txt |grep -vE 'NoModule|Unknown|NO DIMM|Not Specified|Empty'| awk '{print $0"-PC"}' >.mem-1.txt
fi


paste -d "*" .mem_Manufacturer.txt .mem-1.txt .mem_speed.txt |grep -iv empty >.mem.txt


mem=`paste -d "*" .mem.txt .pn.txt`

echo  "$mem"
#rm -rf ./.*.txt ./*.txt
