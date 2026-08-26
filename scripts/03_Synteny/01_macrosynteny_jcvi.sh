#!/bin/bash
# ==============================================================================
# Description: Macro-synteny and chromosomal rearrangement analysis
# Software: JCVI utility libraries v1.6.5, LAST v1651
# ==============================================================================

# ==============================================================================
# Input variables (Modify these according to your environment)
# ==============================================================================
# 1. Species prefixes
# The list below shows the species used in our study as an example.
# PLEASE REPLACE these with the prefixes of your own target and reference species.
# Note: Ensure that ${TARGET}.gff, ${TARGET}.pep, ${REF}.gff, and ${REF}.pep exist.
TARGET="Rhodeus_sinensis"
REFERENCES=(
    "Danio_rerio"
    "Ctenopharyngodon_idella"
)

# 2. Synteny filtering parameters
# Minimum number of collinear gene pairs to form a synteny block
MINSPAN=30

# ==============================================================================
# Run Analysis
# ==============================================================================

echo "=========================================================="
echo "Step 1: Format preparation (GFF to BED)"
echo "=========================================================="
# Convert GFF3 files to BED format for structural analysis
echo "Converting target species (${TARGET}) GFF to BED..."
python -m jcvi.formats.gff bed --type=mRNA --key=ID ${TARGET}.gff > ${TARGET}.bed

for REF in "${REFERENCES[@]}"; do
    echo "Converting reference species (${REF}) GFF to BED..."
    python -m jcvi.formats.gff bed --type=mRNA --key=ID ${REF}.gff > ${REF}.bed
done

echo "=========================================================="
echo "Step 2: Pairwise Ortholog Search using LAST"
echo "=========================================================="
# All-against-all local alignments using LAST aligner
for REF in "${REFERENCES[@]}"; do
    echo "Running ortholog search: ${TARGET} vs ${REF}..."
    python -m jcvi.compara.catalog ortholog $TARGET $REF --aligner=last --no_strip_names
done

echo "=========================================================="
echo "Step 3: Synteny Block Filtering"
echo "=========================================================="
# Rigorously filter synteny blocks (minimum consecutive pairs, simple paths)
for REF in "${REFERENCES[@]}"; do
    echo "Filtering synteny blocks for ${TARGET} vs ${REF}..."
    python -m jcvi.compara.synteny screen --minspan=${MINSPAN} --simple ${TARGET}.${REF}.anchors ${TARGET}.${REF}.anchors.new
done

echo "=========================================================="
echo "Step 4: Karyotype Visualization"
echo "=========================================================="
# Generate Karyotype plot
# Note: This step strictly requires user-configured 'seqids' and 'layout' files in the directory.
echo "Drawing karyotype plot..."
python -m jcvi.graphics.karyotype seqids layout

echo "=========================================================="
echo "Macro-synteny analysis complete."
echo "=========================================================="
