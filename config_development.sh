#!/usr/bin/env bash

# location for maven and tools is bin folder in user home directory
userbin=~/bin
[ ! -d $userbin ] && mkdir $userbin

# install java 8, set it as default and remove java 1.7
sudo yum -y shell ./yum-script

# make java 8 the default java option
echo 2 | sudo alternatives --config java
 
#download maven archive and unpack it
pushd $userbin
curl http://apache.spinellicreations.com/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz | tar xz
popd
 
# install aws python client. Required by setup.py
sudo python -m pip install boto3

# Remove '-e none ' from generated aws docker login string (leaving -e none results in error)
# Store the corrected docker login command in a file and then execute it
aws ecr get-login | tee orig-docker-login.txt | sed 's/-e none //g' | tee docker-login 
source docker-login

