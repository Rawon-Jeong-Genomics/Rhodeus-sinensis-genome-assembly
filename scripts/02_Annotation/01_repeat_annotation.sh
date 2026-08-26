#!/bin/bash
# ==============================================================================
# Description: De novo and homology-based repeat identification and masking
# Software: RepeatModeler2, RepeatMasker v4.1.5 (RMBLAST v2.14.1+), famdb.py v0.4.3
# ==============================================================================

# ==============================================================================
# Input variables (Modify these according to your environment)
# ==============================================================================
# 1. Input genome
GENOME_FASTA="assembly.fasta"
THREADS=24

# 2. Database and taxonomy parameters
DB_NAME="genome_db"
# Enter the target taxonomic group for Dfam extraction (e.g., Actinopterygii, Teleostei)
TAXON="Actinopterygii" 
COMBINED_LIB="combined_repeats.fa"

# 3. Software paths
# Conda path for famdb.py (Update the path to match your conda environment)
FAMDB_PATH="/opt/miniconda3/envs/repeatmasker/share/RepeatMasker/famdb.py"

# ==============================================================================
# Run Analysis
# ==============================================================================

echo "=========================================================="
echo "Step 1: Building database for RepeatModeler"
echo "=========================================================="
BuildDatabase -name $DB_NAME $GENOME_FASTA

echo "=========================================================="
echo "Step 2: Running RepeatModeler for de novo repeat identification"
echo "=========================================================="
# This produces the '${DB_NAME}-families.fa' file
RepeatModeler -database $DB_NAME -pa $THREADS -LTRStruct

echo "=========================================================="
echo "Step 3: Extracting known repeats using Dfam"
echo "=========================================================="
# Extract known repeats for the specified taxonomic group
$FAMDB_PATH families -f fasta_name -a -d "$TAXON" > known_repeats.fa

echo "=========================================================="
echo "Step 4: Merging de novo and known repeat libraries"
echo "=========================================================="
cat ${DB_NAME}-families.fa known_repeats.fa > $COMBINED_LIB

echo "=========================================================="
echo "Step 5: Running RepeatMasker using the combined library"
echo "=========================================================="
RepeatMasker -pa $THREADS \
             -lib $COMBINED_LIB \
             -dir . \
             -gff \
             -xsmall \
             $GENOME_FASTA

echo "=========================================================="
echo "Repeat annotation complete. Soft-masked genome and results saved."
echo "=========================================================="
