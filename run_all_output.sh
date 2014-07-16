#!/bin/bash

for query_file in /root/impala-tpcds-kit/shark_queries/*sql
do
  FILENAME=`basename $query_file`
  OUTPUT_FILENAME="/tmp/query_out_$FILENAME"
  echo "Running query in file $query_file and sending output to $OUTPUT_FILENAME"
  # Clear buffer cache before each query!

  TIMER_FILE_RELATIVE=`ls -t /tmp/spark-root/ | head -1`
  TIMER_FILE="/tmp/spark-root/$TIMER_FILE_RELATIVE"

  OUTPUT_FOLDER="/mnt/output/$FILENAME-$TIMER_FILE_RELATIVE"


  

  python /root/shark/bin/dev/clear-buffer-cache.py
  /root/shark/bin/shark-withinfo -h localhost -p 4444 -i $query_file > $OUTPUT_FILENAME 2>&1

  cp -r $TIMER_FILE $OUTPUT_FOLDER
  cp $OUTPUT_FILENAME $OUTPUT_FOLDER

done
