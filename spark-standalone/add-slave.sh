
cp /root/spark-ec2/slaves /root/spark/conf/
/root/spark-ec2/copy-dir /root/spark/conf

SPARK_CLUSTER_URL=`cat /root/spark-ec2/cluster-url`

echo "Adding slaves to $SPARK_CLUSTER_URL"

for node in $ADD_SLAVES; do
  ssh -t -t $SSH_OPTS root@$node "/root/spark/sbin/start-slave.sh 1 $SPARK_CLUSTER_URL"
done
