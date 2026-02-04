#!/bin/bash
# Description: De novo repeat identification and masking
# Journal: G3: Genes, Genomes, Genetics (Genome Report)
# Software: RepeatModeler v2.0.3, RepeatMasker v4.1.2

# 1. Path Setup
FINAL_ASSEMBLY="asm.final.FINAL.full_mask"
THREADS=32
DB_NAME="Rhodeus"

echo "=========================================================="
echo "Step 1: Building database for RepeatModeler"
echo "=========================================================="
# Building a database from the final assembly
BuildDatabase -name $DB_NAME $FINAL_ASSEMBLY

echo "=========================================================="
echo "Step 2: Running RepeatModeler for de novo repeat identification"
echo "=========================================================="
# Running RepeatModeler to identify repeat families
# This produces the 'Rhodeus-families.fa' file
RepeatModeler -database $DB_NAME -pa $THREADS -LTRStruct

echo "=========================================================="
echo "Step 3: Running RepeatMasker using the custom library"
echo "=========================================================="
# Masking the genome using the identified repeat families
# Input library: Rhodeus-families.fa
RepeatMasker -pa $THREADS \
             -lib ${DB_NAME}-families.fa \
             -xsmall \
             -gff \
             $FINAL_ASSEMBLY

echo "=========================================================="
echo "Repeat annotation complete. Results saved in *.masked and *.gff"
echo "=========================================================="
