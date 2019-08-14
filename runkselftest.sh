#!/bin/bash
if [ `whoami` = root ];then
	echo "正在使用root用户，准备测试"
else
	echo "请使用root用户"
	exit 1
fi

dpkg -l linux-source > /dev/null 2>&1

if [[ 0 -eq $? ]] && [[ -d /usr/src/linux-source-4.19 ]];then
	cp kselftest /usr/src/linux-source-4.19
	cd /usr/src/linux-source-4.19/
else
	echo "下载并解压linux-source"
	apt-get install linux-source -y 
	cd /usr/src
	xz -d linux-source-4.19.tar.xz
	tar -xvf linux-source-4.19.tar
	cp kselftest /usr/src/linux-source-4.19
	cd linux-source-4.19
fi

echo "安装所需的包"
apt-get install -y libpopt-dev libfuse-dev llvm linux-libc-dev pkgconf rsync libcap-dev libcap-ng-dev libnuma-dev libpython2.7-dev libpython3.7-dev > /dev/null 2>&1

echo "build kernel selftest"
cp /boot/config-`uname -r` .config
yes| sudo  make oldconfig
make -C tools/testing/selftests 
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


