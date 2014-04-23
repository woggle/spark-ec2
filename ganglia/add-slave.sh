#!/bin/bash

GANGLIA_PACKAGES="ganglia ganglia-web ganglia-gmond ganglia-gmetad"

for node in $ADD_SLAVES; do
  ssh -t -t $SSH_OPTS root@$node "if ! rpm --quiet -q $GANGLIA_PACKAGES; then yum install -q -y $GANGLIA_PACKAGES; fi" & sleep 0.3
done

wait

/root/spark-ec2/copy-dir /etc/ganglia/

for node in $ADD_SLAVES; do
  ssh -t -t $SSH_OPTS root@$node "/etc/init.d/gmond restart"
done
