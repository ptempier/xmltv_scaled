#!/bin/bash

GRABBER="tv_grab_fr_telerama"
BASE="/data"
DATA="$BASE/xmldata"
GRAB_OPTS="--no_aggregatecat -delay 5 --casting"
GRAB_CFG="/data/tv_grab_fr_telerama_tnt.config"

function delete_file {
	CLEAN="$1"

	DATE="$(date -d "- $CLEAN days" +"%Y_%m_%d")"
	DEL_FILE="$DATA/$GRABBER.xml.$DATE"
	if [[ -f "$DEL_FILE" ]]
	then
		echo "Deleting $DEL_FILE , $CLEAN days old"
	        rm -f "$DEL_FILE"
	fi
}

function clean_old {
	delete_file 2
	delete_file 3
	delete_file 4
	delete_file 5
}

function get_xml {
	echo "'$FILE' is older than $DAYS days, updating"
        "$BASE/$GRABBER" --config-file "$GRAB_CFG"  --days 1 --offset "$OFFSET" $GRAB_OPTS   --output "$FILE"
        cat "$FILE" | socat - "/tvheadend/epggrab/xmltv.sock"
        clean_old
}

function run_if_older {

	OFFSET="$1"
	DAYS="$2"
	if [ -z $OFFSET ] ; then echo "Missing offset, skipping"; return 1 ; fi
	if [ -z $DAYS ]   ; then echo "Missing hours, skipping" ; return 1 ; fi

	AGE="$( echo "$DAYS" |awk '{print $1 * 12 * 3600}')"
	DATE="$(date -d "+ $OFFSET days" +"%Y_%m_%d")"
	FILE="$DATA/$GRABBER.xml.$DATE"

	NOW=$(( $(date +"%s" ) ))
	FDATE=$(date -d "+ $OFFSET days" +"%s")

        if	! grep -q '</tv>' "$FILE"		; then echo "Getting incomplete file $FILE"     ; get_xm
	elif 	[[ -f "$FILE" ]] 			; then echo "File is present, skiping : $FILE" 
	elif	[[ ! -f "$FILE" ]] 			; then echo "Getting missing file $FILE"	; get_xml 
	elif	[[ ! -s "$FILE" ]]			; then echo "Getting empty file $FILE"		; get_xml 
	elif	[[ "$(( $NOW - $FDATE ))" -gt "$AGE" ]]	; then echo "Time to get file : $FILE"		; get_xml 
	else
		echo "Strange situation"
	fi
}

function main {
	echo "start $(date)"
	run_if_older 00 0.2 #2.4h
	run_if_older 01 01  #12h
	run_if_older 02 02  #24h
	run_if_older 03 03
	run_if_older 04 04 
	run_if_older 05 05
	run_if_older 06 06
	run_if_older 07 07 
	run_if_older 08 08 
	run_if_older 09 09 
	run_if_older 10 10  #5j
	echo "end $(date)"
}

main
