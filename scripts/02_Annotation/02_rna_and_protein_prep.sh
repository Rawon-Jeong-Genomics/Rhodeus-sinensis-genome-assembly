#!/bin/bash
# Description: RNA-seq data processing, STAR alignment, and protein evidence preparation
# Journal: G3: Genes, Genomes, Genetics (Genome Report)
# Software: fastp (v0.24.0), STAR (v2.7.11b), SAMtools, cd-hit

# 1. Path Setup & Variables
THREADS_FASTP=16
THREADS_STAR=24
THREADS_BAM=16

RAW_R1="../../../rawon_hic_data/SUB15924303_related_data/R_sinensis_RNAseq_R1.fastq.gz"
RAW_R2="../../../rawon_hic_data/SUB15924303_related_data/R_sinensis_RNAseq_R2.fastq.gz"
TRIMMED_R1="trimmed_R1.fastq.gz"
TRIMMED_R2="trimmed_R2.fastq.gz"

MASKED_GENOME="Rhodeus_sinensis_genome.fasta.masked"
STAR_INDEX="star_index"
STAR_OUT_DIR="star_trimmed_out/"
FINAL_BAM="${STAR_OUT_DIR}Aligned.sortedByCoord.out.bam"

echo "=========================================================="
echo "Step 1: RNA-seq quality filtering and trimming (fastp)"
echo "=========================================================="
fastp -i $RAW_R1 -I $RAW_R2 \
      -o $TRIMMED_R1 -O $TRIMMED_R2 \
      -h report.html \
      -w $THREADS_FASTP

echo "=========================================================="
echo "Step 2: Building STAR Genome Index"
echo "=========================================================="
STAR --runThreadN $THREADS_STAR \
     --runMode genomeGenerate \
     --genomeDir $STAR_INDEX \
     --genomeFastaFiles $MASKED_GENOME \
     --genomeSAindexNbases 13

echo "=========================================================="
echo "Step 3: RNA-seq Alignment to Masked Genome (STAR)"
echo "=========================================================="
# Increasing open file limit for STAR
ulimit -n 65535

STAR --runThreadN $THREADS_STAR \
     --genomeDir $STAR_INDEX \
     --readFilesIn $TRIMMED_R1 $TRIMMED_R2 \
     --readFilesCommand zcat \
     --outFileNamePrefix $STAR_OUT_DIR \
     --outSAMtype BAM SortedByCoordinate \
     --outSAMattributes NH HI NM MD XS \
     --outSAMstrandField intronMotif \
     --alignIntronMax 100000

echo "=========================================================="
echo "Step 4: Indexing the sorted BAM file (SAMtools)"
echo "=========================================================="
samtools index -@ $THREADS_BAM $FINAL_BAM

echo "=========================================================="
echo "Step 5: Preparing Protein Evidence for BRAKER3"
echo "=========================================================="
# Clean up previous BRAKER directory if it exists
rm -rf braker3_final_annotation

# Download Actinopterygii (taxid:7898) proteins from UniProt
echo "Downloading UniProt Actinopterygii proteins..."
wget "https://rest.uniprot.org/uniprotkb/stream?format=fasta&query=%28taxonomy_id%3A7898%29" -O uniprot_actinopt.fasta

# Clean fasta headers
sed 's/ .*//' uniprot_actinopt.fasta > proteins_uniprot_clean.fa

# Reduce redundancy using cd-hit (90% identity)
echo "Running cd-hit to cluster proteins..."
cd-hit -i proteins_uniprot_clean.fa -o proteins_final_ready.fa -c 0.9 -n 5 -M 16000

echo "=========================================================="
echo "RNA-seq alignment and protein preparation complete."
echo "=========================================================="
