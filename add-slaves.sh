#!/bin/bash
# Make sure we are in the spark-ec2 directory
cd /root/spark-ec2

# Load the environment variables specific to this AMI
source /root/.bash_profile

# Load the cluster variables set by the deploy script
source ec2-variables.sh

echo "$ADD_SLAVES" >> /root/spark-ec2/slaves
SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=5"

TODO="$ADD_SLAVES"
TRIES="0"                          # Number of times we've tried so far
echo "SSH'ing to other cluster nodes to approve keys..."
while [ "e$TODO" != "e" ] && [ $TRIES -lt 4 ] ; do
  NEW_TODO=
  for slave in $TODO; do
    echo $slave
    ssh $SSH_OPTS $slave echo -n
    if [ $? != 0 ] ; then
        NEW_TODO="$NEW_TODO $slave"
    fi
  done
  TRIES=$[$TRIES + 1]
  if [ "e$NEW_TODO" != "e" ] && [ $TRIES -lt 4 ] ; then
      sleep 15
      TODO="$NEW_TODO"
      echo "Re-attempting SSH to cluster nodes to approve keys..."
  else
      break;
  fi
done

echo "RSYNC'ing /root/spark-ec2 to new cluster nodes..."
for node in $ADD_SLAVES; do
  echo $node
  rsync -e "ssh $SSH_OPTS" -az /root/spark-ec2 $node:/root &
  scp $SSH_OPTS ~/.ssh/id_rsa $node:.ssh &
  sleep 0.3
done
wait

# NOTE: We need to rsync spark-ec2 before we can run setup-slave.sh
# on other cluster nodes
echo "Running slave setup script on other cluster nodes..."
for node in $ADD_SLAVES; do
  echo $node
  ssh -t -t $SSH_OPTS root@$node "spark-ec2/setup-slave.sh" & sleep 0.3
done
wait

/root/spark-ec2/copy-dir /root/spark/conf

for module in $MODULES; do
  echo "Adding slaves $module"
  if [[ -e $module/add-slave.sh ]]; then
    source $module/add-slave.sh
  fi
done
