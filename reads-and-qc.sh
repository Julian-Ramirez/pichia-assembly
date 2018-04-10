#!/bin/sh

# Now we are going to download our short reads and do some quality control.
# We are going to put our files in a directory called "~/sga-assembly/pichia"
# To download our sequences we are going to use NCBI's Short Read Assembly (SRA) toolkit.

# I started by making a directory to place our data in
cd sga-assembly

mkdir pichia

cd pichia

mkdir short-reads

cd short-reads


# We are going to assemble pichia pastourus as a test run. The first step is to downlload our short
# reads from NCBI's server.

fastq-dump --gzip --split-files ERR1294016

# Then we will qc our data and interpret the results
