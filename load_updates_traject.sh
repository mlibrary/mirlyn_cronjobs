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

SOLR_PORT=8026

LOGDIR=/l/solr-vufind/apps/ht_traject/logs
TODAY=`date '+%Y-%m-%d'`
LOG_DATE=`date '+%Y-%m-%d_%H:%M:%S'`
LOAD_LOG=$LOGDIR/load_updates_${LOG_DATE}.log

echo Working on host $HOST > $LOAD_LOG
echo "`date`: start" >> $LOAD_LOG

cd /l/solr-vufind/apps/ht_traject/
SOLR_PORT=$SOLR_PORT /l/solr-vufind/apps/ht_traject/bin/catchup_today umich > $LOAD_LOG 2> $LOAD_LOG


# tar up index for backup purposes

if [ -z "$SKIP_MIRLYN_SOLR_BACKUP" ]; then 
  echo "`date`: tar up index for backup purposes" >> $LOAD_LOG
  PROD_SOLR=/l/solr-vufind/solrs/serve_solr/solr
  mv -f /l/solr-backup/vufind/prod.tgz /l/solr-backup/vufind/prod.tgz.old
  if ! tar -czf /l/solr-backup/vufind/prod.tgz --directory ${PROD_SOLR} --exclude .nfs* biblio; then
    /bin/echo "WARN: after release, error creating solr tar backup...look into it"
    abort "WARN: after release, error creating solr tar backup...look into it"
  fi
  echo "`date`: backup finished" >> $LOAD_LOG
else
  echo "Skipping backup since SKIP_MIRLYN_SOLR_BACKUP is set" >> $LOAD_LOG;
fi
  
echo "`date`: done" >> $LOAD_LOG

# Get the hostname

HOSTNAME=`hostname -s`
# Figure out if we have errors or warning or not

SUBJECT="Mirlyn Update on $HOSTNAME for $TODAY"
ERRORS=`grep -c ERROR $LOAD_LOG`
WARNINGS=`grep -c WARN $LOAD_LOG`

if [ $ERRORS != "0" ]; then
  SUBJECT="PROBLEM: $SUBJECT had $ERRORS errors";
elif [ $WARNINGS != "0" ]; then
  SUBJECT="PROBLEM: $SUBJECT had $WARNINGS warnings";
else
  SUBJECT="CLEAN: $SUBJECT";
fi

cat $LOAD_LOG | mail -s"$SUBJECT" dueberb@umich.edu
#vufind-admin@umich.edu
exit 0
