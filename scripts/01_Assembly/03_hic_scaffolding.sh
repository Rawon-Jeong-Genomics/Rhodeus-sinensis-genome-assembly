#!/bin/bash
# ==============================================================================
# Description: Chromosome-level scaffolding using Hi-C data
# Software: Juicer v1.6, 3D-DNA v180922
# ==============================================================================

# ==============================================================================
# Input variables (Modify these according to your environment)
# ==============================================================================
# 1. Input files
GENOME_FASTA="assembly.fasta"
HIC_R1="hic_R1.fastq.gz"
HIC_R2="hic_R2.fastq.gz"

# 2. Parameters
PREFIX="genome"
ENZYME="DpnII" 
THREADS=32

# 3. Software installation paths (Must be changed to your actual paths)
JUICER_DIR="/opt/software/juicer"
THREED_DNA_DIR="/opt/software/3d-dna"

# ==============================================================================
# Run Analysis
# ==============================================================================

echo "=========================================================="
echo "Preparation: Setting up Juicer fastq directory"
echo "=========================================================="
# Juicer strictly requires fastq files to be inside a directory named 'fastq'
mkdir -p fastq
ln -sf $(realpath $HIC_R1) fastq/
ln -sf $(realpath $HIC_R2) fastq/

echo "=========================================================="
echo "Step 1: Generating restriction site positions and chrom.sizes"
echo "=========================================================="
# Generate DpnII site positions using Juicer's utility script
python ${JUICER_DIR}/misc/generate_site_positions.py $ENZYME $PREFIX $GENOME_FASTA

# Generate chrom.sizes for Juicer
samtools faidx $GENOME_FASTA
cut -f1,2 ${GENOME_FASTA}.fai > ${PREFIX}.chrom.sizes

echo "=========================================================="
echo "Step 2: Running Juicer mapping pipeline"
echo "=========================================================="
# -z: reference fasta, -y: site positions file, -p: chrom sizes, -s: enzyme name
bash ${JUICER_DIR}/scripts/juicer.sh \
     -g $PREFIX \
     -z $GENOME_FASTA \
     -y ${PREFIX}_${ENZYME}.txt \
     -p ${PREFIX}.chrom.sizes \
     -s $ENZYME \
     -t $THREADS

echo "=========================================================="
echo "Step 3: Scaffolding with 3D-DNA pipeline"
echo "=========================================================="
# Using 'merged_nodups.txt' generated from the Juicer step
# 3D-DNA will produce a .hic file for visualization in Juicebox
bash ${THREED_DNA_DIR}/run-asm-pipeline.sh $GENOME_FASTA aligned/merged_nodups.txt

echo "=========================================================="
echo "Scaffolding complete."
echo "Output is ready for manual curation in Juicebox."
echo "=========================================================="
