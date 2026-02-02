#!/bin/bash
# Description: PacBio data preprocessing and Hybrid assembly using HASLR v0.8a1
# Journal: G3: Genes, Genomes, Genetics (Genome Report)
# Software: seqtk v1.3, HASLR v0.8a1

# 1. Data Preprocessing: Convert multiple FASTQ files to a single FASTA
echo "=========================================================="
echo "Step 1: Merging and converting FASTQ to FASTA..."
echo "=========================================================="

# Combine 3 PacBio HiFi cells and convert to FASTA format using seqtk
cat R_sinensis_PacBio_HiFi_cell1.fastq.gz \
    R_sinensis_PacBio_HiFi_cell2.fastq.gz \
    R_sinensis_PacBio_HiFi_cell3.fastq.gz | seqtk seq -a - > R_sinensis_PacBio_HiFi_combined.fasta

# Compress the combined FASTA file
gzip R_sinensis_PacBio_HiFi_combined.fasta

# 2. Hybrid Assembly using HASLR
echo "=========================================================="
echo "Step 2: Starting Hybrid Assembly with HASLR v0.8a1..."
echo "=========================================================="

# Define input file paths
PACBIO_COMBINED="R_sinensis_PacBio_HiFi_combined.fasta.gz"
ILLUMINA_R1="/mnt/data2/rawon_hic_data/01.illumina/RS29_S38_L002_R1_001.fastq.gz"
ILLUMINA_R2="/mnt/data2/rawon_hic_data/01.illumina/RS29_S38_L002_R2_001.fastq.gz"

# Set parameters
THREADS=60
GENOME_SIZE="0.8G"
OUTPUT_DIR="rs_hic"

# Running HASLR
# -l: long reads, -x: read type (pacbio), -s: short reads
haslr.py -t $THREADS \
         -o $OUTPUT_DIR \
         -g $GENOME_SIZE \
         -l $PACBIO_COMBINED \
         -x pacbio \
         -s $ILLUMINA_R1 $ILLUMINA_R2

echo "=========================================================="
echo "Assembly process completed successfully."
echo "=========================================================="
