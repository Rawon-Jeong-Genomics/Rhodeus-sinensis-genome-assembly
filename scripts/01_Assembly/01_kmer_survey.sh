#!/bin/bash
# Description: K-mer frequency analysis for genome size estimation of Rhodeus sinensis
# Journal: G3: Genes, Genomes, Genetics (Genome Report)
# Software: Jellyfish v2.2.6, GenomeScope v2.0 (v1.0.0)

# Define input file paths and analysis parameters
# Replace these with the actual paths on your server if necessary
ILLUMINA_R1="R_sinensis_WGS_R1.fastq.gz"
ILLUMINA_R2="R_sinensis_WGS_R2.fastq.gz"
KMER_SIZE=21
THREADS=10
HASH_SIZE="100M"

echo "=========================================================="
echo "Step 1: Running Jellyfish count..."
echo "=========================================================="
# -m: k-mer size (21-mer)
# -s: initial hash size
# -t: number of threads
# -C: count canonical k-mers
jellyfish count -m $KMER_SIZE -s $HASH_SIZE -t $THREADS -C \
    $ILLUMINA_R1 $ILLUMINA_R2 \
    -o rs_k21.jf

echo "=========================================================="
echo "Step 2: Generating k-mer histogram for GenomeScope..."
echo "=========================================================="
# This histogram file serves as the input for GenomeScope2.0
jellyfish histo rs_k21.jf > rs_k21.histo

echo "=========================================================="
echo "Step 3: Estimating genome properties with GenomeScope 2.0..."
echo "=========================================================="
# -i: input histogram file
# -o: output directory for plots and summary
# -p: ploidy (2 for diploid Rhodeus sinensis)
# -k: k-mer size used during the Jellyfish counting step
genomescope2 -i rs_k21.histo -o ./out -p 2 -k $KMER_SIZE

echo "Analysis complete. Results are saved in the './out' directory."
echo "Check 'summary.txt' for estimated genome size and heterozygosity."
