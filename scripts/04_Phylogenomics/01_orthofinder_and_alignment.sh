#!/bin/bash
# ==============================================================================
# Description: Orthologous gene family identification and multiple sequence alignment
# Software: OrthoFinder
# ==============================================================================

# ==============================================================================
# Input variables (Modify these according to your environment)
# ==============================================================================
# 1. Input directory
# Specify the directory containing all the protein FASTA files (.faa)
INPUT_DIR="./"

# 2. Hardware parameters
THREADS=24

# ==============================================================================
# Run Analysis
# ==============================================================================

echo "=========================================================="
echo "Step 1: Running OrthoFinder for Orthologous Gene Identification"
echo "=========================================================="
# -f: Input directory containing protein sequences
# -S: Sequence search program (diamond)
# -M: Method for gene tree inference (msa)
# -T: Tree inference program (fasttree is used for initial fast tree inference)
# -t: Number of threads for sequence search
# -a: Number of threads for analysis
orthofinder -f $INPUT_DIR -S diamond -M msa -T fasttree -t $THREADS -a $THREADS

echo "=========================================================="
echo "OrthoFinder complete."
echo "Check the 'OrthoFinder' results directory for 'SpeciesTreeAlignment.fa'."
echo "=========================================================="
