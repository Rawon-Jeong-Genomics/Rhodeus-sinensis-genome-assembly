#!/bin/bash
# Description: Chromosome-level scaffolding using Hi-C data
# Journal: G3: Genes, Genomes, Genetics (Genome Report)
# Software: Juicer v1.6, 3D-DNA v180922
# Restriction Enzyme: DpnII

# 1. Path and File Setup
# Replace with the actual filename of your HASLR final assembly
GENOME_FASTA="rs_hybrid_assembly.fasta"
HIC_R1="R_sinensis_HiC_R1.fastq.gz"
HIC_R2="R_sinensis_HiC_R2.fastq.gz"
ENZYME="DpnII" 
THREADS=40

echo "=========================================================="
echo "Step 1: Generating restriction site positions and chrom.sizes"
echo "=========================================================="
# Generate DpnII site positions using Juicer's utility script
# This avoids uploading the massive .txt file to GitHub
python /path/to/juicer/misc/generate_site_positions.py $ENZYME rs_genome $GENOME_FASTA

# Generate chrom.sizes for Juicer
samtools faidx $GENOME_FASTA
cut -f1,2 ${GENOME_FASTA}.fai > rs_genome.chrom.sizes

echo "=========================================================="
echo "Step 2: Running Juicer mapping pipeline"
echo "=========================================================="
# -z: reference fasta, -y: site positions file, -p: chrom sizes, -s: enzyme name
# The Hi-C fastq files should be located in a 'fastq' directory as per Juicer requirements
bash /path/to/juicer/scripts/juicer.sh \
     -g rs_genome \
     -z $GENOME_FASTA \
     -y rs_genome_${ENZYME}.txt \
     -p rs_genome.chrom.sizes \
     -s $ENZYME \
     -t $THREADS

echo "=========================================================="
echo "Step 3: Scaffolding with 3D-DNA pipeline"
echo "=========================================================="
# Using 'merged_nodups.txt' generated from the Juicer step
# 3D-DNA will produce a .hic file for visualization in Juicebox
bash /path/to/3d-dna/run-asm-pipeline.sh $GENOME_FASTA aligned/merged_nodups.txt

echo "=========================================================="
echo "Scaffolding complete. Output is ready for manual curation in Juicebox."
echo "=========================================================="
