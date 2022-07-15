ls /dev/sr0 >/dev/null 2>&1
if [ `echo $?` = "0" ]
then


num=1
while [ $num -le 10 ]
do
mkdir /cdrom >/dev/null 2>&1
a=`mount /dev/sr0 /cdrom 2>/dev/null`
if [ $? = 0 ] ;then


        ls /cdrom >.1.txt
a=`cat .1.txt`
        umount /cdrom
        eject /dev/sr0 2>/dev/null
        break

else
sleep 1
fi
num=$(( $num + 1 ))
done

if [ -n "$a" ]
then
echo  " 光驱测试结果：OK"
else
echo  " 光驱测试结果： 不合格"
fi

else

        echo "" | grep -v "^$"
fi

