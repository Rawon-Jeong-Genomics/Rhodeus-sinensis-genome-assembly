#!/bin/bash
# Description: Homology-based gene prediction using Exonerate
# Journal: G3: Genes, Genomes, Genetics (Genome Report)
# Software: Exonerate v2.58.3
# Evidence: Danio rerio (Zebrafish) protein sequences (GCF_000002035.6)

# 1. Path Setup
QUERY_PROTEIN="Danio_rerio_proteins.fasta"
TARGET_GENOME="asm.final.FINAL.full_mask.soft.fasta"
OUTPUT_DIR="./homology_results"

mkdir -p $OUTPUT_DIR

echo "=========================================================="
echo "Step: Running Exonerate with protein2genome model"
echo "=========================================================="

# Running Exonerate with basic options
# --model protein2genome: Aligns protein sequences to a genomic DNA sequence
# --showtargetgff: Outputs the alignment in GFF format for downstream integration
# --showalignment: Set to no to keep the output file size manageable
exonerate --model protein2genome \
          --showtargetgff yes \
          --showalignment no \
          --query $QUERY_PROTEIN \
          --target $TARGET_GENOME \
          > $OUTPUT_DIR/rs_exonerate_output.gff

echo "=========================================================="
echo "Homology mapping complete. Result: $OUTPUT_DIR/rs_exonerate_output.gff"
echo "=========================================================="
