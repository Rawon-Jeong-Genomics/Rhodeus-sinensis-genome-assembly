#!/bin/bash
# Description: De novo transcriptome assembly using Trinity
# Journal: G3: Genes, Genomes, Genetics (Genome Report)
# Software: Trinity v2.11.0 (or your version)

# 1. Path and File Setup
RNA_R1="R_sinensis_RNAseq_R1.fastq.gz"
RNA_R2="R_sinensis_RNAseq_R2.fastq.gz"
THREADS=32
MAX_MEMORY="100G"

echo "=========================================================="
echo "Starting De novo Transcriptome Assembly with Trinity..."
echo "=========================================================="

# Running Trinity
# --trimmomatic: Performs quality trimming (results in 'qtrim' files)
# --seqType: Type of reads (fq for fastq)
# --left/--right: Input paired-end reads
Trinity --seqType fq \
        --max_memory $MAX_MEMORY \
        --left $RNA_R1 \
        --right $RNA_R2 \
        --CPU $THREADS \
        --trimmomatic \
        --output ./trinity_out

echo "=========================================================="
echo "Transcriptome assembly complete. Output: trinity_out/Trinity.fasta"
echo "=========================================================="
