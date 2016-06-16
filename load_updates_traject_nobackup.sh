#!/bin/bash

# 
# use traject to load file of new and updated marc records, and delete records in delete file
#

function abort {
  echo $1
  echo $1 >> $LOAD_LOG
  mail -s"problem in $0" vufind-admin@umich.edu << EOF
$1
EOF
  exit 1
}

SOLR_PORT=8024

LOGDIR=/l/solr-vufind/apps/ht_traject/logs
TODAY=`date '+%Y-%m-%d'`
LOG_DATE=`date '+%Y-%m-%d_%H:%M:%S'`
LOAD_LOG=$LOGDIR/load_updates_${LOG_DATE}.log

echo Working on host $HOST > $LOAD_LOG
echo "`date`: start" >> $LOAD_LOG

cd /l/solr-vufind/apps/ht_traject/
SOLR_PORT=$SOLR_PORT /l/solr-vufind/apps/ht_traject/bin/catchup_today umich > $LOAD_LOG 2> $LOAD_LOG

cat $LOAD_LOG | mail -s"$0" dueberb@umich.edu
exit 0
