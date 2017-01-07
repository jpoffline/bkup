#!/bin/bash


LOGFILE=$1

echo ""
echo "Summary of backup-log file " $LOGFILE
echo ""

declare -a ITEMS=("STRTBKP" "Number of files:" "Number of files transferred:" "Total bytes sent:")
declare -a DITEMS=("loc: " " #files:     " " #updated:   " " #bytes sent:")
NITEMS=${#ITEMS[@]}

IFS=$'\n'
logcontent=`cat $LOGFILE`

tot_n_files=0
tot_n_files_trans=0
tot_bytes_sent=0

for line in $logcontent; do
    
    
    for (( ii=0; ii<${NITEMS}; ii++ )); do
        i=${ITEMS[$ii]}
        
        if [[ $line == $i* ]]
        then
            varr=$(echo $line | sed 's/'$i' *//' )
            echo ${DITEMS[$ii]} $varr
            if [[ $ii == 1 ]] 
            then
                tot_n_files=$(($tot_n_files+$varr))
            fi;
            if [[ $ii == 2 ]] 
            then
                tot_n_files_trans=$(($tot_n_files_trans+$varr))
            fi;
            if [[ $ii == 3 ]] 
            then
                tot_bytes_sent=$(($tot_bytes_sent+$varr))
            fi;
        fi
    done;

done;

echo ""
echo "Total #files inspected: "$tot_n_files
echo "Total #files updated:   "$tot_n_files_trans
echo "Total #bytes sent:      "$tot_bytes_sent
echo ""