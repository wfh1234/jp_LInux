a=`dmidecode -t 39 |grep 'Manufacturer:'`
b=`dmidecode -t 39 |grep 'Revision:'`
c=`dmidecode -t 39 |grep 'Max Power Capacity:'`
d=`dmidecode -t 39 |grep 'Status:'`

e=`dmidecode -t 39 |grep 'Revision:' |grep  'O.E.M'`
if [ -z "$e" ]
then
echo  "$a"
echo  "$b"
echo  "$c"
echo  "$d"
else
echo "" | grep -v "^$"

fi


