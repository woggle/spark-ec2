pushd /root

echo "Setting up Spark"
mv spark spark_old
git clone -b proc_logging_minimal https://github.com/kayousterhout/spark-1.git spark
cp spark_old/conf/* spark/conf/
pushd spark
SPARK_HADOOP_VERSION=2.0.0-mr1-cdh4.2.0 sbt/sbt clean assembly publish-local
popd

echo "Setting up Hive"
sudo yum install ant
git clone https://github.com/amplab/hive.git -b shark-0.11
pushd hive
ant package
popd

echo "Setting up Shark"
mv shark shark_old
git clone -b branch-0.9 https://github.com/amplab/shark.git
cp shark_old/conf/shark-env.sh shark/conf/
pushd shark
SPARK_HADOOP_VERSION=2.0.0-mr1-cdh4.2.0 sbt/sbt package
popd

echo "Copying files to cluster"
spark-ec2/copy-dir --delete spark
spark-ec2/copy-dir --delete shark
spark-ec2/copy-dir --delete hive

popd
