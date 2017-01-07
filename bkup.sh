#!/bin/bash

# Define the version of this back-up script
VERSION=0.1

# Scrape the .bkp-config filename from the first command line argument
SOURCE_FILENAME=$1'.bkp-config'

# Get a pretty-version of the date-time
DATEP=`date +%Y-%m-%d_%H:%M:%S`

# Get a date-time stamp
DATE=$(echo $DATEP | sed 's/[-_:]//g')

# Define the items for exclusion from the backups. Generally, just exclude the *.git files
EXCLUSIONS=*.git



# Make sure that cat only works with new-lines as the delimiter
IFS=$'\n'

# Scrape out the first line of the sources file
line=$(head -1 $SOURCE_FILENAME)

# Scrape out the #tgt: specifier from the sources file
TARGET=$(echo $line | sed 's/#tgt:*//' )

BKP_LOGS_DIR=$TARGET'/bkp-logs'
mkdir -p $BKP_LOGS_DIR
LOGFILE=$BKP_LOGS_DIR'/log-'$DATE'.txt'
TGTROOT=$TARGET
TARGET=$TARGET'/bkp'

# Read in the .bkp-config file
filelines=`cat $SOURCE_FILENAME`

# Write the header to screen
echo ""
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo " BACKUP SCRIPT       v"$VERSION
echo "   USER:            " $USER
echo "   DATE:            " $DATEP
echo "   BACKUP-TARGET:   " $TARGET
echo "   BKP-CONFIG-FILE: " $SOURCE_FILENAME
echo "   LOG FILE:        " $LOGFILE
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "* begin"


# Write the header of the logfile
echo '' > $LOGFILE
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - -" >> $LOGFILE
echo "backup script "                                        >> $LOGFILE
echo "bkup-version " $VERSION                                >> $LOGFILE
echo "bkup-tgt     " $TARGET                                 >> $LOGFILE
echo "bkup-user    " $USER                                   >> $LOGFILE
echo "bkup-date    " $DATEP                                  >> $LOGFILE
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - -" >> $LOGFILE
echo '' >> $LOGFILE

# Loop through the items in the .bkp-config file;
#   treat #'s as comment lines.
#   everything else, is a file path to be backed up
for src in $filelines ; do
    if [[ $src != *'#'* ]]
    then
        echo "** backing up: "$src
        echo 'STRTBKP '$src >> $LOGFILE
        # Do the rsync; pipe the output to the logfile
        rsync -r -av --exclude=$EXCLUSIONS --progress $src $TARGET --stats >> $LOGFILE
        echo 'ENDBKP' >> $LOGFILE
        echo '' >> $LOGFILE
    fi
done;    

echo "* backup complete"

# Parse the logfile for this backup
# pipe the output to a summary file.
LOG_SUMMARY_FILE=$TGTROOT'/bkp-log-summary.txt'
./bkup-parse-log.sh $LOGFILE > $LOG_SUMMARY_FILE
cat $LOG_SUMMARY_FILE

# Copy the summary file to the bkp-logs dir
cp $LOG_SUMMARY_FILE $BKP_LOGS_DIR'/log-'$DATE'-summary.txt'



echo "- - - - - - - - - - DONE - - - - - - - - - -"
echo ""