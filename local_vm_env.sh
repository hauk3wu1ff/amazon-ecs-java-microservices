#!/usr/bin/bash

# install python-virtualenv package
yum -y install python-virtualenv

# setup python 2.7 virtual environment and activate it
pythonenvfolder=~/python28
virtualenv ${pythonenvfolder}
source ${pythonenvfolder}/bin/activate
