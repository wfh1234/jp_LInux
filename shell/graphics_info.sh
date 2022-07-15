a=`sudo lshw -C video |grep 'product:' |grep -viE 'nvidia|geforce' |cut -f2 -d ':'`
echo  "$a"


