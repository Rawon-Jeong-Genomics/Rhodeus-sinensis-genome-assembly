#!/bin/bash
# ==============================================================================
# Description: K-mer frequency analysis for genome size estimation
# Software: Jellyfish v2.2.6, GenomeScope v2.0
# ==============================================================================

# ==============================================================================
# Input variables
# ==============================================================================
READS_R1="reads_R1.fastq.gz"
READS_R2="reads_R2.fastq.gz"
KMER_SIZE=21
THREADS=10
HASH_SIZE="100M"
PLOIDY=2
OUTPUT_DIR="./genomescope_out"
PREFIX="kmer_counts"

# ==============================================================================
# Run Analysis
# ==============================================================================

echo "=========================================================="
echo "Step 1: Running Jellyfish count..."
echo "=========================================================="
# -m: k-mer size
# -s: initial hash size
# -t: number of threads
# -C: count canonical k-mers
jellyfish count -m $KMER_SIZE -s $HASH_SIZE -t $THREADS -C \
    $READS_R1 $READS_R2 \
    -o ${PREFIX}.jf

echo "=========================================================="
echo "Step 2: Generating k-mer histogram for GenomeScope..."
echo "=========================================================="
# This histogram file serves as the input for GenomeScope2.0
jellyfish histo ${PREFIX}.jf > ${PREFIX}.histo

echo "=========================================================="
echo "Step 3: Estimating genome properties with GenomeScope 2.0..."
echo "=========================================================="
# -i: input histogram file
# -o: output directory for plots and summary
# -p: ploidy (e.g., 2 for diploid)
# -k: k-mer size used during the Jellyfish counting step
genomescope2 -i ${PREFIX}.histo -o $OUTPUT_DIR -p $PLOIDY -k $KMER_SIZE

echo "=========================================================="
echo "Analysis complete."
echo "Results are saved in the '${OUTPUT_DIR}' directory."
echo "Check '${OUTPUT_DIR}/summary.txt' for estimated genome size and heterozygosity."
echo "=========================================================="
