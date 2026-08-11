#!/bin/bash
# Description: De novo and homology-based repeat identification and masking
# Journal: G3: Genes, Genomes, Genetics (Genome Report)
# Software: RepeatModeler2, RepeatMasker v4.1.5 (RMBLAST v2.14.1+), famdb.py v0.4.3

# 1. Path Setup
ASSEMBLY="Rhodeus_sinensis_genome.fasta"
THREADS=24
DB_NAME="my_fish_db"
PREFIX="Rhodeus_sinensis"
FAMDB_PATH="/home/jrw/miniconda3/envs/repeatmasker/share/RepeatMasker/famdb.py"

echo "=========================================================="
echo "Step 1: Building database for RepeatModeler"
echo "=========================================================="
BuildDatabase -name $DB_NAME $ASSEMBLY

echo "=========================================================="
echo "Step 2: Running RepeatModeler for de novo repeat identification"
echo "=========================================================="
# This produces the '${PREFIX}-families.fa' file
RepeatModeler -database $DB_NAME -pa $THREADS -LTRStruct

echo "=========================================================="
echo "Step 3: Extracting known Actinopterygii repeats using Dfam"
echo "=========================================================="
$FAMDB_PATH families -f fasta_name -a -d "Actinopterygii" > actinopterygii_repeats.fa

echo "=========================================================="
echo "Step 4: Merging de novo and known repeat libraries"
echo "=========================================================="
cat ${PREFIX}-families.fa actinopterygii_repeats.fa > combined_Rhodeus_Actinopterygii.fa

echo "=========================================================="
echo "Step 5: Running RepeatMasker using the combined library"
echo "=========================================================="
RepeatMasker -pa $THREADS \
             -lib combined_Rhodeus_Actinopterygii.fa \
             -dir . \
	     -gff \
             -xsmall \
             $ASSEMBLY

echo "=========================================================="
echo "Repeat annotation complete. Soft-masked genome and results saved."
echo "=========================================================="
