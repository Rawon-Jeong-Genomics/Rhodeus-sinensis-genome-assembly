#!/bin/bash
# ==============================================================================
# Description: Long read data preprocessing and Hybrid assembly using HASLR
# Software: seqtk v1.3, HASLR v0.8a1
# ==============================================================================

# ==============================================================================
# Input variables (Modify these according to your environment)
# ==============================================================================
# 1. Long reads (e.g., PacBio CLR or Nanopore)
# Separate multiple files with spaces if there are more than one.
LONG_READ_INPUTS="long_read_cell1.fastq.gz long_read_cell2.fastq.gz long_read_cell3.fastq.gz"
LONG_READ_COMBINED="combined_long_reads.fasta"
LONG_READ_TYPE="pacbio" # Enter 'pacbio' or 'nanopore'

# 2. Short reads (Illumina)
ILLUMINA_R1="short_reads_R1.fastq.gz"
ILLUMINA_R2="short_reads_R2.fastq.gz"

# 3. Assembly parameters
GENOME_SIZE="1.0G" # Estimated genome size
THREADS=60
OUTPUT_DIR="./haslr_output"

# ==============================================================================
# Run Analysis
# ==============================================================================

echo "=========================================================="
echo "Step 1: Merging and converting FASTQ to FASTA..."
echo "=========================================================="

# Combine multiple long read files and convert to FASTA format using seqtk
cat $LONG_READ_INPUTS | seqtk seq -a - > $LONG_READ_COMBINED

# Compress the combined FASTA file
gzip $LONG_READ_COMBINED

echo "=========================================================="
echo "Step 2: Starting Hybrid Assembly with HASLR..."
echo "=========================================================="

# Running HASLR
# -l: long reads, -x: read type (pacbio or nanopore), -s: short reads
haslr.py -t $THREADS \
         -o $OUTPUT_DIR \
         -g $GENOME_SIZE \
         -l ${LONG_READ_COMBINED}.gz \
         -x $LONG_READ_TYPE \
         -s $ILLUMINA_R1 $ILLUMINA_R2

echo "=========================================================="
echo "Assembly process completed successfully."
echo "Results are saved in the '${OUTPUT_DIR}' directory."
echo "=========================================================="
