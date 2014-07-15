# Exit if any commands fail.                                                    
set -e
set -o pipefail

pushd ~

echo "Starting build"
spark-ec2/build_all_from_source_2.4.0a.sh

echo "Restarting Spark"
spark/sbin/stop-all.sh
sleep 10
spark/sbin/start-all.sh

echo "Starting sharkserver in background"
screen -S sharkserver -d -m shark/bin/shark --service sharkserver -p 4444
sleep 10

echo "Creating tables"
pushd impala-tpcds-kit
python ~/spark-ec2/rewriter.py tpcds-env.sh -r -k=SCALE_FACTOR -v=5
./push-bits.sh
./set-node-num.sh
./gen-dims.sh
./run-gen-facts.sh 

./shark-create-external-tables.sh
./shark-load-dims.sh
./shark-load-store_sales.sh
popd

echo "Running queries"
./shark_queries/run_all.sh
