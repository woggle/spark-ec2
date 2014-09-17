# Exit if any commands fail.
set -e
set -o pipefail

pushd /root

echo "-------------------Installing Protobufs"
wget https://protobuf.googlecode.com/files/protobuf-2.4.0a.tar.gz
tar -xvzf protobuf-2.4.0a.tar.gz
pushd protobuf-2.4.0a
./configure
make
sudo make install
sudo ldconfig
popd

echo "-------------------Installing Maven"
wget http://apache.spinellicreations.com/maven/maven-3/3.2.1/binaries/apache-maven-3.2.1-bin.tar.gz
tar -xvzf apache-maven-3.2.1-bin.tar.gz
mv apache-maven-3.2.1 /usr/local/apache-maven/

echo "-------------------Building Hadoop"
git clone -b branch-2.0.2-withlogging-protobuf2.4.0a https://github.com/kayousterhout/hadoop-common.git
pushd hadoop-common
/usr/local/apache-maven/bin/mvn package -DskipTests -Pdist -Dmaven.javadoc.skip=true -e -X
# mvn install puts Hadoop in the ~/.m2 directory, where Spark/Shark can find it.
/usr/local/apache-maven/bin/mvn install -DskipTests
popd

echo "-------------------Setting up Spark"
mv spark spark_old
git clone -b proc_logging_1.1_master https://github.com/kayousterhout/spark-1.git spark
cp spark_old/conf/* spark/conf/
pushd spark
# Similar to mvn install, sbt/sbt publish-local puts Spark in the ~/.ivy2 directory,
# where Shark can find it.
SPARK_HADOOP_VERSION=2.0.2-kay sbt/sbt clean assembly publish-local
popd

echo "Copying files to cluster"
spark-ec2/copy-dir --delete spark

popd
