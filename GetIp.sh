#!/bin/sh
interf="$1"

if [ x"${interf}" = "x" ]; then
	echo "Interface name is required">&2
	return 1
fi

self_IP=`ifconfig | awk -v interf="${interf}" '{\
	if($1==interf){ flag=0;next;}; \
	if(flag==0){ \
		if ($0~/inet addr/) { \
			split ($2,arr,":"); \
			print arr[2]; \
			exit; \
		} \
	}; \
 }'`
echo ${self_IP}