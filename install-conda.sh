#!/bin/sh

# This is a script for installing all of the dependencies required to run a String Graph Assembly pipeline. 
# I am making this script to make setting up new virtual machines convient. These depencencies will be installed
# using the conda package manager. 

# These are are the steps for installing Miniconda for an ubuntu/debian based distro of linux.
mkdir sga-assembly
cd sga-assembly
mkdir install-files
cd install-files
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh

cd ..

# Now we must close the terminal and start a new one so we can install the rest of the dependencies using conda
