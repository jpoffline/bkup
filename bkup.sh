#!/bin/bash

#----------------------------------------------------------------
#
# Backup script
#   J Pearson, Jan 2017
#
VERSION=0.1
#
#----------------------------------------------------------------

# Check the command line arguments.
if ! [[ $1 ]]
then
    echo "    ERROR: need to provide the name of the .bkp-config file ... exiting"
    exit
fi

# Scrape the .bkp-config filename from the first command line argument
SOURCE_FILENAME=$1'.bkp-config'

# Get a pretty-version of the date-time
DATEP=`date +%Y-%m-%d_%H:%M:%S`

# Get a date-time stamp from the pretty-version of the date-time;
# remove the hype, underscore, and colon from the pretty date-time.
DATE=$(echo $DATEP | sed 's/[-_:]//g')

# Define the items for exclusion from the backups. 
# Generally, just exclude the *.git files
EXCLUSIONS=*.git

# Make sure that cat only works with new-lines as the delimiter
IFS=$'\n'

# Scrape out the first line of the sources file
line=$(head -1 $SOURCE_FILENAME)

# Scrape out the #tgt: specifier from the sources file
TARGET=$(echo $line | sed 's/#tgt:*//' )

# Define the backup-logs directory:
#   - logs go in the target directory, in "bkp-logs"
BKP_LOGS_DIR=$TARGET'/bkp-logs'

# Make sure the backup-logs folder exists; if not, create it.
mkdir -p $BKP_LOGS_DIR
LOGFILE=$BKP_LOGS_DIR'/log-'$DATE'.txt'
TGTROOT=$TARGET

# The actual backup goes in the target directory, in "bkp"
TARGET=$TARGET'/bkp'

# Read in the .bkp-config file
filelines=`cat $SOURCE_FILENAME`

# Write the header-meta-data to screen
echo ""
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo " BACKUP SCRIPT       v"$VERSION
echo "   USER:            "  $USER
echo "   DATE:            "  $DATEP
echo "   BACKUP-TARGET:   "  $TARGET
echo "   BKP-CONFIG-FILE: "  $SOURCE_FILENAME
echo "   LOG FILE:        "  $LOGFILE
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

# Construct the file name of the bkp-log-summary
LOG_SUMMARY_FILE=$TGTROOT'/bkp-log-summary.txt'

# Call the bkup-parse-log tool; output gets piped to log-summary file.
./bkup-parse-log.sh $LOGFILE > $LOG_SUMMARY_FILE

# Cat the content of the bkp-log-summary file to screen
cat $LOG_SUMMARY_FILE

# Copy the summary file to the bkp-logs dir
cp $LOG_SUMMARY_FILE $BKP_LOGS_DIR'/log-'$DATE'-summary.txt'

echo ""
echo "* summary data saved to "$LOG_SUMMARY_FILE
echo "- - - - - - - - - - DONE - - - - - - - - - -"
echo ""

#----------------------------------------------------------------
# EOF
#----------------------------------------------------------------