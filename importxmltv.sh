#!/bin/bash
#set -x

GRABBER="tv_grab_fr_telerama"
BASE="/data"
GRAB_OPTS="--no_aggregatecat"

function rotate_files {

        echo "rotating files"
        mv "$BASE/$GRABBER.xml.10" "$BASE/$GRABBER.xml.9"
        mv "$BASE/$GRABBER.xml.9"  "$BASE/$GRABBER.xml.8"
        mv "$BASE/$GRABBER.xml.8"  "$BASE/$GRABBER.xml.7"
        mv "$BASE/$GRABBER.xml.7"  "$BASE/$GRABBER.xml.6"
        mv "$BASE/$GRABBER.xml.6"  "$BASE/$GRABBER.xml.5"
        mv "$BASE/$GRABBER.xml.5"  "$BASE/$GRABBER.xml.4"
        mv "$BASE/$GRABBER.xml.4"  "$BASE/$GRABBER.xml.3"
        mv "$BASE/$GRABBER.xml.3"  "$BASE/$GRABBER.xml.2"
        mv "$BASE/$GRABBER.xml.2"  "$BASE/$GRABBER.xml.1"
        mv "$BASE/$GRABBER.xml.1"  "$BASE/$GRABBER.xml.0"

}

function run_if_older {
        OFFSET="$1"
        HOURS="$2"
        AGE="$(( $HOURS * 3600 ))"

        FILE="$BASE/$GRABBER.xml.$OFFSET"

        NOW=$(( $(date +"%s" ) ))
        FDATE=$(stat -c "%Y" "$FILE")

        if  [[ ! -f "$FILE" ]]
        then
                FDATE=0
        fi

        if [[ "$(( $NOW - $FDATE ))" -gt "$AGE" ]]
        then
                echo "'$FILE' is older than $HOURS hours, updating"
                "$BASE/$GRABBER" --config-file "$BASE/$GRABBER.config"  --days 1 --offset "$OFFSET" $GRAB_OPTS   --output "$FILE"
                cat "$FILE" | socat - "/tvheadend/epggrab/xmltv.sock"
                if [[ "$OFFSET" -eq "$2" ]]
                then
                        rotate_file
                fi
        else
                echo "'$FILE' is newer than $HOURS hours, no change"
        fi
}

function main {

        run_if_older 0  3            #3h = 3600*3
        run_if_older 1  $(( 12*1 )) #12h
        run_if_older 2  $(( 12*2 )) #24h
        run_if_older 3  $(( 12*3 ))
        run_if_older 4  $(( 12*4 ))
        run_if_older 5  $(( 12*5 ))
        run_if_older 6  $(( 12*6 ))
        run_if_older 7  $(( 12*7 ))
        run_if_older 8  $(( 12*8 ))
        run_if_older 9  $(( 12*9 ))
        run_if_older 10 $(( 12*10 )) #5j
}
main                         
