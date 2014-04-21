#!/bin/bash

for node in $ADD_SLAVES; do
  ssh -t -t $SSH_OPTS root@$node "if ! rpm --quiet -q $GANGLIA_PACKAGES; then yum install -q -y $GANGLIA_PACKAGES; fi" & sleep 0.3
done

wait

for node in $ADD_SLAVES; do
  ssh -t -t $SSH_OPTS root@$node "/etc/init.d/gmond restart"
done
