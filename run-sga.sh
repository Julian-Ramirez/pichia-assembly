#! /bin/bash -x

#
# Example assembly of 50bp Pichia P. reads
#

# Point IN1 and IN2 to the pichia short reads


IN1=/media/server/Disk/pichia-assembly/sga-assembly/pichia/short-reads/ERR1294016_1.fastq.gz
IN2=/media/server/Disk/pichia-assembly/sga-assembly/pichia/short-reads/ERR1294016_2.fastq.gz



#
# Parameters
#

# Program paths
SGA_BIN=sga
BWA_BIN=bwa
SAMTOOLS_BIN=samtools
BAM2DE_BIN=sga-bam2de.pl
ASTAT_BIN=sga-astat.py

# The number of threads to use
CPU=8

# Correction k-mer 
CORRECTION_K=41

# The minimum overlap to use when computing the graph.
# The final assembly can be performed with this overlap or greater
MIN_OVERLAP=15

# The overlap value to use for the final assembly
ASSEMBLE_OVERLAP=25

# Branch trim length
TRIM_LENGTH=400

# The minimum length of contigs to include in a scaffold
MIN_CONTIG_LENGTH=200

# The minimum number of reads pairs required to link two contigs
MIN_PAIRS=10

#
# Dependency checks
#

# Check the required programs are installed and executable
prog_list="$SGA_BIN $BWA_BIN $SAMTOOLS_BIN $BAM2DE_BIN $ASTAT_BIN"
for prog in $prog_list; do
    hash $prog 2>/dev/null || { echo "Error $prog not found. Please place $prog on your PATH or update the *_BIN variables in this script"; exit 1; }
done 

# Check the files are found
file_list="$IN1 $IN2"
for input in $file_list; do
    if [ ! -f $input ]; then
        echo "Error input file $input not found"; exit 1;
    fi
done

echo "start script"
date

#
# Preprocessing
#

echo "Preprocessing"
date

# Preprocess the data to remove ambiguous basecalls
$SGA_BIN preprocess --pe-mode 1 -o reads.pp.fastq $IN1 $IN2

#
# Error Correction
#

echo "Error Correction"
date


# Build the index that will be used for error correction
# As the error corrector does not require the reverse BWT, suppress
# construction of the reversed index
$SGA_BIN index -a ropebwt -t $CPU --no-reverse reads.pp.fastq

# Perform k-mer based error correction.
# The k-mer cutoff parameter is learned automatically.
$SGA_BIN correct -k $CORRECTION_K --learn -t $CPU -o reads.ec.fastq reads.pp.fastq

#
# Primary (contig) assembly
#

echo "Primary (contig) assembly"
date


# Index the corrected data.
$SGA_BIN index -a ropebwt -t $CPU reads.ec.fastq

# Remove exact-match duplicates and reads with low-frequency k-mers
$SGA_BIN filter -x 2 -t $CPU reads.ec.fastq

# Compute the structure of the string graph
$SGA_BIN overlap -m $MIN_OVERLAP -t $CPU reads.ec.filter.pass.fa

# Perform the contig assembly
$SGA_BIN assemble -m $ASSEMBLE_OVERLAP --min-branch-length $TRIM_LENGTH -o primary reads.ec.filter.pass.asqg.gz

echo "End Assembly"
date

#
# Assess the quality of the assembly using QUAST
#

quast -t $CPU --est-ref-size 9430000 primary-contigs.fa
