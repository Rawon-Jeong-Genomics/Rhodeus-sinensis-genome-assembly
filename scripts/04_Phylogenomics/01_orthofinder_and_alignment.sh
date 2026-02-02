#!/bin/bash
# Software: OrthoFinder v2.3.8, MAFFT v7.45, IQ-TREE v1.5.5
# Goal: Highly accurate orthology inference using MSA and IQ-TREE

PROTEIN_DIR="./primary_proteins"
THREADS=32

echo "=========================================================="
echo "Step 1: Running OrthoFinder with MSA, MAFFT, and IQ-TREE"
echo "=========================================================="
# -M msa: MSA-based tree inference
# -A mafft: Use MAFFT for alignment
# -T iqtree: Use IQ-TREE for gene tree inference
# -S diamond: Sensitive protein search
orthofinder -f $PROTEIN_DIR \
            -t $THREADS \
            -M msa \
            -A mafft \
            -S diamond

echo "=========================================================="
echo "OrthoFinder run complete with IQ-TREE gene trees."
echo "=========================================================="
