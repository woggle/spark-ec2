# get node count
NODES=`wc -l < /root/impala-tpcds-kit/dn.txt`

# Exit if any commands fail.                                                    
set -e
set -o pipefail

# house keeping for output scripts
mkdir -p /mnt/output
cp run_all_output.sh ~/impala-tpcds-kit/shark_queries/

pushd ~

echo "emacs"
yum -y install emacs

echo "Starting build"
spark-ec2/build_all_from_source_2.4.0a.sh

pushd ~/spark-ec2
echo "Updating ephemeral-hdfs/conf/mapred-site.xml"
cp mapred-site.xml ~/ephemeral-hdfs/conf/mapred-site.xml
popd

echo "Restarting Spark"
spark/sbin/stop-all.sh
sleep 10
spark/sbin/start-all.sh

echo "Starting sharkserver in background"
ssh localhost 'screen -S sharkserver -d -m shark/bin/shark --service sharkserver -p 4444'
sleep 10

echo "Removing old tpcds data"
ephemeral-hdfs/bin/hdfs dfs -rmr /user/root/tpcds

echo "Creating tables"
pushd impala-tpcds-kit
SF=$(($NODES*15*3))
python ~/spark-ec2/rewriter.py tpcds-env.sh -r -k=SCALE_FACTOR -v=$SF
./push-bits.sh
./set-node-num.sh
./gen-dims.sh
./run-gen-facts.sh 

sleep 10
./shark-create-external-tables.sh
sleep 10
./shark-load-dims.sh
sleep 10
./shark-load-store_sales.sh

echo "Running queries"
./shark_queries/run_all_output.sh
popd

