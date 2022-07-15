fibre=`lspci |grep -i Fibre`
if [ ! -n "$fibre" ]
then
  echo "" | grep -v "^$"
else
echo
lspci -vvv |grep -i fibre -A 100 |grep 'Part number:' | cut -f 2 -d ':' >.1.txt
lspci |grep -i Fibre |awk '{print "  "$4"   "$6"   "$7"   "$8"   "$9"    "$13}' >.2.txt
lspci -vvv |grep -i fibre -A 100 |grep -E 'Serial number:' |cut -f 2 -d ':' >.3.txt
a=`paste  .1.txt .2.txt .3.txt |sed 's/^[ \t]*//g'`
echo  "$a"
fi
