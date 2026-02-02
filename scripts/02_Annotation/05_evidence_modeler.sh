#!/bin/bash
# Description: Final gene model integration using EVidenceModeler (EVM)
# Journal: G3: Genes, Genomes, Genetics (Genome Report)
# Software: EVM v1.1.1

# 1. Path Definition
BASE_DIR="."
GENOME="${BASE_DIR}/asm.final.FINAL.full_mask.soft.fasta"

# Evidence Files (GFF3)
TRANSCRIPTS="rs_pasa_transcripts.gff3" # From PASA
HOMOLOGY="rs_exonerate_output.gff"     # From Exonerate
AB_INITIO_BRAKER="braker_ab_initio/augustus.gff"
AB_INITIO_SNAP="rs_snap_output.gff3"

echo "=========================================================="
echo "Step 1: Creating Weights File"
echo "=========================================================="
# EVM uses a weights file to decide which evidence to prioritize.
cat <<EOF > weights.txt
TRANSCRIPT  PASA    10
PROTEIN     Exonerate   5
ABINITIO_PREDICTION BRAKER  1
ABINITIO_PREDICTION SNAP    1
EOF

echo "=========================================================="
echo "Step 2: Running EVidenceModeler"
echo "=========================================================="
# -g: genome, -p: proteins (homology), -t: transcripts, -a: ab initio
# --weights: weights file, --output_file_root: prefix for output
evidence_modeler.pl --genome $GENOME \
    --weights weights.txt \
    --gene_predictions $AB_INITIO_BRAKER $AB_INITIO_SNAP \
    --protein_alignments $HOMOLOGY \
    --transcript_alignments $TRANSCRIPTS \
    --output_file_root rs_final_gene_models \
    --threads 16

echo "=========================================================="
echo "EVM Complete. Final consensus gene set: rs_final_gene_models.evm.gff3"
echo "=========================================================="
