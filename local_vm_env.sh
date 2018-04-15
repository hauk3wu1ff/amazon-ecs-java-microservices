#!/usr/bin/bash
echo "This script sets environment variables, run script with: source ./local_vm_env.sh"
 
# install python-virtualenv package
sudo yum -y install python-virtualenv

# setup python 2.7 virtual environment and activate it
pythonenvfolder=~/python27
if [[ ! -d ${pythonenvfolder} ]] ; then virtualenv ${pythonenvfolder} ; fi
source ${pythonenvfolder}/bin/activate

