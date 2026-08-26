#!/bin/bash
# ==============================================================================
# Description: Prepare protein datasets for OrthoFinder by retaining only the longest isoforms
# Software: AGAT v1.2.0, seqtk
# ==============================================================================

# ==============================================================================
# Input variables (Modify these according to your environment)
# ==============================================================================
# 1. List of comparative species prefixes
# The list below shows the species used in our study. 
# PLEASE REPLACE this list with the prefixes of your own target species.
# Make sure your input files are named as ${SP}${GFF_SUFFIX} and ${SP}${PROT_SUFFIX}
SPECIES=(
    "Danio_rerio"
    "Ctenopharyngodon_idella"
    "Gasterosteus_aculeatus"
    "Gobio_gobio"
    "Labeo_rohita"
    "Misgurnus_anguillicaudatus"
    "Onychostoma_macrolepis"
    "Oryzias_latipes"
    "Phoxinus_phoxinus"
    "Pseudorasbora_parva"
)

# 2. Input/Output file suffixes
GFF_SUFFIX=".gff"
PROT_SUFFIX="_protein.faa"
OUT_SUFFIX="_FINAL_proteins.faa"

# ==============================================================================
# Run Analysis
# ==============================================================================

echo "=========================================================="
echo "Preparing longest isoform proteins for comparative genomics"
echo "=========================================================="

for SP in "${SPECIES[@]}"; do
    echo "Processing ${SP}..."
    
    # 1. Keep longest isoform in GFF
    agat_sp_keep_longest_isoform.pl --gff ${SP}${GFF_SUFFIX} -o ${SP}_longest.gff
    
    # 2. Extract protein IDs for the longest CDS
    awk -F '\t' '$3 == "CDS"' ${SP}_longest.gff | grep -o 'protein_id=[^;]*' | cut -d '=' -f 2 | sort | uniq > ${SP}_longest_ids.txt
    
    # 3. Extract corresponding protein sequences
    seqtk subseq ${SP}${PROT_SUFFIX} ${SP}_longest_ids.txt > ${SP}${OUT_SUFFIX}
    
    echo "${SP} final protein count: $(wc -l < ${SP}_longest_ids.txt)"
done

echo "=========================================================="
echo "All protein datasets are ready for OrthoFinder analysis."
echo "=========================================================="
