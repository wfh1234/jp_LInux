a=`lspci |grep -i nvidia`
if [ -n "$a" ]
then
b=`nvidia-smi 2>/dev/null`



echo  "$b"
else
echo "" | grep -v "^$"
fi
