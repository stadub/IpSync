#/bin/sh

ip_file_path='/root/Dropbox/Settings/IPs'

bin_files='IPSaveBox.sh IPGetBox.sh GetIp.sh'
bin_dir='/usr/bin'

CheckFileExists(){
	file="$2"
	folder="$1"
        if [ -f ${folder}/${file} ]; then
                echo "File \"${file}\" already exists in folder \"${folder}\", owerwrite?(yes/no)"
                while :
		do
			read res
			if [ x"${res}" = x"yes" ]; then
                        	echo "Remowing file \"${file}\"...">&2
                        	rm -r ${folder}/${file}
				return 0;
               		elif [  x"${res}" = x"no" ]; then
                	        echo "Exiting...">&2
        	                exit 1
	                fi
		done
        fi

}
CopyFile(){
	file="$2"
        folder="$1"
	chmod +x ${file}
	echo "Creating link to file \"${file}\" to the folder \"${bin_dir}\"...">&2
	CheckFileExists  ${folder} ${file}
	ln -s $PWD/${file} ${folder}/${file}
}

for file in $bin_files
do
	CopyFile  ${bin_dir} ${file}
done

GetIpCommand='/usr/bin/GetIp.sh "eth0"'

SaveBoxCommmand="/usr/bin/IPSaveBox.sh ${ip_file_path}"

cron_file="CronExec.sh"

echo "${GetIpCommand} | ${SaveBoxCommmand}" > "/etc/cron.hourly/${cron_file}"
chmod +x  "/etc/cron.hourly/${cron_file}"

echo "${GetIpCommand} | ${SaveBoxCommmand} --force" > "/etc/cron.daily/${cron_file}"
chmod +x  "/etc/cron.daily/${cron_file}"
