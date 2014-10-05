#!/bin/sh

#IPSaveBox.sh/IPGetBox.sh

meName=`basename "$0"`

StdErr(){
	message="$1"
	echo "$message" >&2
}

IPSaveArgsList="{h,help}{1$file,-f,--file|:2$pc,-p,--pc|:3$ip,-i,--ip|:,--force}"
IPGetArgsList="{h,help}{1$file,-f,--file|:2$pc,-p,--pc}"

Usage(){

if [ "$meName" = "IPSaveBox.sh" ]; then
	UsageIPSave
else
	UsageIPGet
fi
}

File=""
IP=""
PC=""
ForceUpdate=0


GetOpt(){
	args="$@"
	index=0
	
	for arg in $args
do
	index=$(($index + 1 ))
		
	paramName="${arg%%=*}"
	paramVal="${arg#*=}"

	case "$paramName" in
		"-h"|"--help") 
			Usage
			exit 0;;
		
		"-f"|"--file")
			File="$paramVal";;
				
		"-p"|"--pc")
			PC="$paramVal";;
				
		"-i"|"--ip")
			IP="$paramVal";;
		
		"--force")
			ForceUpdate=1;;
		*)
			case $index in
				1) File="${arg}";;
				2) PC="${arg}";;
				3) IP="${arg}";;
				*) Usage; exit 1;;
			esac
			;;
    esac
done
}

UsageIPSave(){
	cat << EOF
Usage:  $meName [options]
        $meName FileName PC_Name IP_Address
        cat IP_Address | $meName FileName [PC_Name]
        cat IP_Address | $meName [options]

Arguments:
    -h, --help           - Shows this uasge gude and exit

    -f, --file=FileName  - Full path to file
    -i, --ip             - Current pc IP Address (can be set trought pipeline)
    -p, --pc [optional]	 - Current pc name (if not set, receives from \`hostname\`)
    --force  [optional]	 - force update value in file
EOF
>&2
}

UsageIPGet(){
	cat  << EOF
Usage:  $meName [options]
        $meName FileName [PC_Name]
Arguments:
    --help, -h           - Shows this uasge gude and exit

    -f, --file=FileName  - Full path to file
    -p, --pc [optional]	 - Current pc name (if not set, receives from \`hostname\`)
EOF
>&2
}

GetOpt "$@"

if ! [ -t 0 ]; then
	read IP
fi

if [ x"${PC}" = "x" ]; then
	PC=`hostname`
	StdErr "PC Name isn't set, seting hostname \"${PC}\""
fi


if [ x"${File}" = "x" ]; then
	StdErr "IPs file name is required"
	Usage
	return 1
fi

if ! [ -f "${File}" ]; then
	StdErr "File \"${File}\" don't exist, creating"
	echo "#PCName|IPAddress|UpdateTime">"${File}"
fi

line=`cat "${File}"| grep "${PC}"`

#read pc_name ip_address date_update <<<"$line"

pc_name="${line%%|*}"
line="${line#*|}"
ip_address="${line%%|*}"
date_set="${line#*|}"

if [ "$meName" = "IPGetBox.sh" ]; then
	echo "${ip_address} ${date_set}"
	return 0;
fi

if [ x"${IP}" = "x" ]; then
	StdErr "IP Address is required"
	Usage
	return 1
fi

if [ "$ip_address" = "${IP}" ]; then	
	if [ $ForceUpdate -ne 1 ]; then
		StdErr "Saved IP Address is actual, no change requared"
		return 0;
	fi
fi

tmp_result=`cat "${File}" | sed '/^'${PC}'|/d'`
echo "${tmp_result}" >"${File}"

curDate=`date +'[%d/%m]%H:%M'`

CurIP="${PC}|${IP}|${curDate}"

echo "$CurIP" >>"${File}"

StdErr "${CurIP}"

# /usr/bin/GetIp.sh 'eth0' | /usr/bin/IPSaveBox.sh ~/Dropbox/Settings/IPs
# ./GetIp.sh 'eth0' | ./IPSaveBox.sh ~/Dropbox/Settings/IPs

#sd-deb|172.20.15.106|[21/03]14:00

# 0  0    * * *   root    /usr/bin/GetIp.sh 'eth0' | /usr/bin/IPSaveBox.sh ~/Dropbox/Settings/IPs