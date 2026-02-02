#!/bin/bash
# Description: Ab initio gene prediction and format conversion
# Journal: G3: Genes, Genomes, Genetics (Genome Report)
# Software: BRAKER v2.1.5, SNAP v2.51.7

# 1. Path Definition
# Set BASE_DIR to the current directory for general use
BASE_DIR="."
SOFTMASKED_GENOME="${BASE_DIR}/asm.final.FINAL.full_mask.soft.fasta"

# Evidence and Parameters
RNA_BAM="star/rna-seq.bam"
THREADS=16
SPECIES="R.sinensis"

echo "=========================================================="
echo "Step 1: Running BRAKER with Augustus"
echo "=========================================================="
# Using RNA-seq BAM to train and predict via Augustus
braker.pl --species=$SPECIES \
          --genome=$SOFTMASKED_GENOME \
          --bam=$RNA_BAM \
          --softmasking \
          --cores $THREADS \
          --AUGUSTUS_ab_initio \
          --skipOptimize \
          --workingdir braker_ab_initio

echo "=========================================================="
echo "Step 2: Running SNAP"
echo "=========================================================="
# SNAP identifies gene structures based on HMMs
snap default.hmm $SOFTMASKED_GENOME > rs_snap_output.zff

echo "=========================================================="
echo "Step 3: Converting SNAP ZFF to GFF3 for EVM"
echo "=========================================================="
# Convert the ZFF output to GFF3 format using SNAP's utility script
perl zff2gff3.pl rs_snap_output.zff > rs_snap_output.gff3

echo "=========================================================="
echo "Ab initio prediction and format conversion complete."
echo "=========================================================="
