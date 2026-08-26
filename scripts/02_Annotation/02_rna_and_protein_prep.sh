#!/bin/bash
# ==============================================================================
# Description: RNA-seq data processing, STAR alignment, and protein evidence preparation
# Software: fastp (v0.24.0), STAR (v2.7.11b), SAMtools, cd-hit
# ==============================================================================

# ==============================================================================
# Input variables (Modify these according to your environment)
# ==============================================================================
# 1. Input genome and RNA-seq reads
MASKED_GENOME="genome.fasta.masked"
RAW_R1="raw_rnaseq_R1.fastq.gz"
RAW_R2="raw_rnaseq_R2.fastq.gz"

# 2. Output directories and files
TRIMMED_R1="trimmed_R1.fastq.gz"
TRIMMED_R2="trimmed_R2.fastq.gz"
STAR_INDEX="star_index"
STAR_OUT_DIR="star_trimmed_out/"
FINAL_BAM="${STAR_OUT_DIR}Aligned.sortedByCoord.out.bam"

# 3. Protein database parameters
# Find the Taxonomy ID at UniProt/NCBI (e.g., 7898 for Actinopterygii, 7952 for Cypriniformes)
TAXON_ID="7898"
PROTEIN_PREFIX="uniprot_proteins"
FINAL_PROTEIN="proteins_final_ready.fa"

# 4. Hardware parameters
THREADS_FASTP=16
THREADS_STAR=24
THREADS_BAM=16

# ==============================================================================
# Run Analysis
# ==============================================================================

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
# Creates an index directory if it doesn't exist
mkdir -p $STAR_INDEX

STAR --runThreadN $THREADS_STAR \
     --runMode genomeGenerate \
     --genomeDir $STAR_INDEX \
     --genomeFastaFiles $MASKED_GENOME \
     --genomeSAindexNbases 13

echo "=========================================================="
echo "Step 3: RNA-seq Alignment to Masked Genome (STAR)"
echo "=========================================================="
# Increasing open file limit for STAR to prevent errors with large genomes
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
# Clean up previous BRAKER directory if it exists to avoid conflicts in the next script
rm -rf braker3_final_annotation

# Download proteins from UniProt using the specified Taxonomy ID
echo "Downloading UniProt proteins for Taxonomy ID: ${TAXON_ID}..."
wget "https://rest.uniprot.org/uniprotkb/stream?format=fasta&query=%28taxonomy_id%3A${TAXON_ID}%29" -O ${PROTEIN_PREFIX}.fasta

# Clean fasta headers (keep only the ID)
sed 's/ .*//' ${PROTEIN_PREFIX}.fasta > ${PROTEIN_PREFIX}_clean.fa

# Reduce redundancy using cd-hit (90% identity)
echo "Running cd-hit to cluster proteins..."
cd-hit -i ${PROTEIN_PREFIX}_clean.fa -o $FINAL_PROTEIN -c 0.9 -n 5 -M 16000

echo "=========================================================="
echo "RNA-seq alignment and protein preparation complete."
echo "=========================================================="
