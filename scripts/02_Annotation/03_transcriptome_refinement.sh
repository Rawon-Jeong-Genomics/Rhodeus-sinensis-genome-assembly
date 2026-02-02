#!/bin/bash
# Description: Transcriptome-based gene structure refinement and GFF3 extraction
# Journal: G3: Genes, Genomes, Genetics (Genome Report)
# Software: PASA (Program to Assemble Spliced Alignments) v2.4.1

# 1. Path and Parameter Definition
# Using current directory as BASE_DIR for better portability
BASE_DIR="."
GENOME_FASTA="${BASE_DIR}/asm.final.FINAL.full_mask.soft.fasta"
TRANSCRIPTS="Trinity.fasta" # De novo assembled transcripts from Trinity
THREADS=32
DB_NAME="rs_pasa_db" # Must match the DATABASE name in alignComplete.txt

echo "=========================================================="
echo "Step 1: Running PASA Alignment Assembly Pipeline"
echo "=========================================================="
# Launching the PASA pipeline to align and assemble transcripts onto the genome
# -c: configuration file (alignComplete.txt)
# -C: creates a new database, -R: runs the alignment/assembly pipeline
# --ALIGNERS: utilizing GMAP and BLAT as default aligners
Launch_PASA_pipeline.pl \
    -c alignComplete.txt -C -R -g $GENOME_FASTA \
    -t $TRANSCRIPTS \
    --ALIGNERS blat,gmap \
    --CPU $THREADS

echo "=========================================================="
echo "Step 2: Extracting GFF3 from PASA SQLite Database"
echo "=========================================================="
# Extracting the refined PASA assemblies into GFF3 format for downstream EVM integration.
# This utility script identifies transcript structures including UTRs.
pasa_asmbls_to_training_set.extract_reference_untranslated_regions.pl \
    --pasa_db $DB_NAME \
    --genome $GENOME_FASTA

# Rename the output file for clarity and consistency in the pipeline
if [ -f "${DB_NAME}.pasa_assemblies.gff3" ]; then
    mv ${DB_NAME}.pasa_assemblies.gff3 rs_pasa_transcripts.gff3
    echo "Success: rs_pasa_transcripts.gff3 has been generated."
else
    echo "Error: PASA output file not found. Please check the PASA logs."
    exit 1
fi

echo "=========================================================="
echo "PASA refinement process complete."
echo "Final output: rs_pasa_transcripts.gff3"
echo "=========================================================="
