#!/usr/bin/bash
# install java 8, set it as default and remove java 1.7
yum -y shell ./yum-script
 
#download maven archive and unpack it
curl http://www-eu.apache.org/dist/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz | tar xz
 
# install aws python client. Required by setup.py
python -m pip install boto3
 
