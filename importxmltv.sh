#!/bin/bash

GRABBER="tv_grab_fr_telerama"
BASE="/data"
DATA="$BASE/xmldata"
GRAB_OPTS="--no_aggregatecat -delay 5"

#to be more secure , need to name  files with 
#date -d "+ 10 days" +"%Y %m %d"

function rotate_files {
	
	echo "Rotating files"
	mv "$DATA/$GRABBER.xml.10" "$DATA/$GRABBER.xml.09"
	mv "$DATA/$GRABBER.xml.09" "$DATA/$GRABBER.xml.08"
	mv "$DATA/$GRABBER.xml.08" "$DATA/$GRABBER.xml.07"
	mv "$DATA/$GRABBER.xml.07" "$DATA/$GRABBER.xml.06"
	mv "$DATA/$GRABBER.xml.06" "$DATA/$GRABBER.xml.05"
	mv "$DATA/$GRABBER.xml.05" "$DATA/$GRABBER.xml.04"
	mv "$DATA/$GRABBER.xml.04" "$DATA/$GRABBER.xml.03"
	mv "$DATA/$GRABBER.xml.03" "$DATA/$GRABBER.xml.02"
	mv "$DATA/$GRABBER.xml.02" "$DATA/$GRABBER.xml.01"
	mv "$DATA/$GRABBER.xml.01" "$DATA/$GRABBER.xml.00"
}

function run_if_older {

	OFFSET="$1"
	DAYS="$2"
	if [ -z $OFFSET ] ; then echo "Missing offset, skipping"; return 1 ; fi
	if [ -z $DAYS ]   ; then echo "Missing hours, skipping" ; return 1 ; fi

	AGE="$( echo "$DAYS" |awk '{print $1 * 12 * 3600}')"

	FILE="$DATA/$GRABBER.xml.$OFFSET"

	NOW=$(( $(date +"%s" ) ))
	FDATE=$(stat -c "%Y" "$FILE")

	if  [[ ! -f "$FILE" ]] ; then FDATE=0 ; fi

	if [[ "$(( $NOW - $FDATE ))" -gt "$AGE" ]]
       	then
		echo "'$FILE' is older than $DAYS days, updating"
		"$BASE/$GRABBER" --config-file "$BASE/$GRABBER.config"  --days 1 --offset "$OFFSET" $GRAB_OPTS   --output "$FILE"
		cat "$FILE" | socat - "/tvheadend/epggrab/xmltv.sock"

		if  [[ "$OFFSET" = "02" ]] ;then rotate_files ; fi
	else
		echo "'$FILE' is newer than $DAYS days, no change"
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
