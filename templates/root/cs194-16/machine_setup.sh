#!/bin/bash

CERT_SUBJECT='/CN=CS194-16 Fall 2014 Lab 9/O=UC Berkeley/L=Berkeley/ST=CA/C=US'

# Create certificate for the cluster (so we can connect w/ HTTPS and not
# send cleartext password).
if [ -f /root/cs194-16/mycert.pem ]; then
    cp /root/cs194-16/mycert.pem /root/mycert.pem
elif [ ! -f /root/mycert.pem ]; then
    pushd /root
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout mycert.pem -out mycert.pem -subj "$CERT_SUBJECT" -batch
    popd
fi


rm /root/cs194-16/lab8*.ipynb

# Kill all of the existing screens.
screen -ls | grep Detached | cut -d . -f 1 | awk '{print $1}' | xargs kill

# Create a python profile to use.
ipython profile create default

PASSWD=`python27 -c '
from random import SystemRandom
lines = map(str.strip, open("/root/cs194-16/diceware_list.txt", "r").readlines())
print " ".join([SystemRandom().choice(lines) for i in range(3)])
' | sed -e "s/'//g"`
echo "********************************************************"
echo `wget -q -O - http://169.254.169.254/latest/meta-data/public-hostname` $PASSWD
echo "$PASSWD" >/root/clear_passwd.txt
python -c "from IPython.lib import passwd; print passwd('$PASSWD')" > /root/.ipython/profile_default/nbpasswd.txt

cp /root/cs194-16/ipython_notebook_config.py /root/.ipython/profile_default/ipython_notebook_config.py
# Naming controls order that these scripts are called; use 00 so this comes first.
cp /root/cs194-16/pyspark-setup.py /root/.ipython/profile_default/startup/00-pyspark-setup.py

echo "Starting ipython notebook in screen..."
# Start the screen in detached mode.
# Be sure to start the notebook in the cs194-16 folder so the notebook for the class shows up.
pushd /root/cs194-16
screen -d -m ipython notebook
popd
