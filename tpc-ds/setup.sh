#!/bin/bash

sudo yum -y install gcc make flex bison byacc

pushd /root

if [! -d "tpcds-kit" ]; then
  echo "Cloning TPC-DS kit for data generation"
  # Need tpc-ds kit in order to generate data (but not
  # used for query generation, because Shark doesn't
  # support the implicit join syntax used by default
  # in the tpc-ds query generation scripts).
  git clone https://github.com/grahn/tpcds-kit.git
  pushd tpcds-kit/tools
  make -f Makefile.suite
  popd
fi

if [! -d "impala-tpcds-kit"]; then
  echo "Cloning TPC-DS scripts"
  git clone https://github.com/kayousterhout/impala-tpcds-kit.git
  pushd impala-tpcds-kit
  cp /root/spark-ec2/slaves dn.txt

  # Need ephemeral-hdfs to be setup before this!
  /root/ephemeral-hdfs/bin/hadoop dfs -mkdir /user/root
  # SCP tpcds-kit and impala-tpcds-kit to each datanode listed in dn.text.
  ./push-bits.sh
  # Creates impala-tpcds-kit on each DataNode and sets the value accordingly
  # (used to determine what portion of distributed data generation is done on
  # each node).
  ./set-nodenum.sh
  ./hdfs-mkdirs.sh
  # Generated out (commented out so can more easily vary scale factor).
  #./gen-dims.sh
  #./run-gen-facts.sh

