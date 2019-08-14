#!/bin/bash
logname=`date "+%Y-%m-%d%H:%M:%S"`
touch kselftest$logname.log
if [ $# -eq 0 ];then
	while read line
	do
			make TARGETS=$line O=/home/deepin/kselftest/$line summary=1 kselftest > /dev/null 2>&1
			if [ $? -eq 0 ];then
	   			echo "Kselftest $line  test succeed!" >>kselftest$logname.log
   			else
	   			echo "Kselftest $line  test failed!"  >>kselftest$logname.log
    			fi
	done < kselftest
else
	for arg in "$*"
	do
		make TARGETS=$arg 0=/home/deepin/kselftest/$arg summary=1 kselftest
	done
fi


