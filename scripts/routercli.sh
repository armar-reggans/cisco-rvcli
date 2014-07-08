#!/bin/sh
echo -n "`hostname`#"
FILES=/tmp/splitDB/*
get_attribute () {
        FILE=$1
        SETTING=$2
        cat /tmp/splitDB/$FILE |grep $SETTING|awk -F= '{print $2}'
}
set_attribute () {
	FILENAME=`echo $1`
	FILE=`echo $FILENAME |  awk '{print toupper($0)}'`
	SETTING=`echo $2 |  awk '{print toupper($0)}'`
	VALUE=$3
	sed -i 's#^\('$SETTING'\s*=\s*\).*$#\1'$VALUE'#' /tmp/splitDB/$FILE
}

get_help () {
	echo ""
	echo ""
	echo "Available Options:"
	echo "------------------"
	echo ""
	echo "                 show SETTING_TYPE: Displays current settings for the specified setting type (Shown Below). "
	echo "  set SETTING_TYPE ATTRIBUTE VALUE: sets a value for an attribute."
	echo "                              help: This screen"
	echo "                              exit: exit this cli to the shell."
	echo "				    save: Write configuration to memory."
	echo "                            reboot: reboots the router."
	echo ""
	echo "Press enter to list the availble setting types..."
	read j
	for f in $FILES
	do
		b=$(basename $f)
		echo "     $b"
	done | more
}

get_settings () {
	FILENAME=`echo $1`
	FILE=`echo $FILENAME |  awk '{print toupper($0)}'`
	READFROM=/tmp/splitDB/$FILE
	for f in $READFROM
	do
		b=$(basename $f)
		grep -v "\[" $f|while read l; do
       	        echo $b $(echo $l|awk -F= '{print $1; $1=""; print $0}')
       	        done
        done
}



while read cmd; do
       # echo "$cmd Third variable $3"
		case ${cmd} in
		exit)
			exit
			;;
		help)
			get_help
			;;
		reboot)
			reboot
			;;
	        "show "*)
		  	get_settings `echo $cmd|sed "s#show ##g"`
		  	;; 
		"set "*)
			FILE=`echo $cmd|awk -F' ' '{print $2}'` 
			SETTING=`echo $cmd|awk -F' ' '{print $3}'`
			ATTRIBUTE=`echo $cmd|awk -F' ' '{$1="";$2="";$3="";print $0}'|sed 's/^ *//'`
		 	set_attribute $FILE $SETTING $ATTRIBUTE 
			;; 	
		"save")
			echo "Writing config to flash memory..."
			saveSettings
			echo "Done!"
			;;
		"")
			;;
		*)
			echo "Command not found."
			;;
        esac
        echo -n "`hostname`#"

done

