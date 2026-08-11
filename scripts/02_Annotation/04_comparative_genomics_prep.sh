#!/bin/bash
# Description: Prepare protein datasets for 11 species for OrthoFinder by retaining only the longest isoforms
# Software: AGAT v1.2.0, seqtk

echo "=========================================================="
echo "Preparing longest isoform proteins for comparative genomics"
echo "=========================================================="

# List of 10 comparative species (excluding R. sinensis which is already processed)
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

for SP in "${SPECIES[@]}"; do
    echo "Processing ${SP}..."
    
    # 1. Keep longest isoform in GFF
    agat_sp_keep_longest_isoform.pl --gff ${SP}.gff -o ${SP}_longest.gff
    
    # 2. Extract protein IDs for the longest CDS
    awk -F '\t' '$3 == "CDS"' ${SP}_longest.gff | grep -o 'protein_id=[^;]*' | cut -d '=' -f 2 | sort | uniq > ${SP}_longest_ids.txt
    
    # 3. Extract corresponding protein sequences
    seqtk subseq ${SP}_protein.faa ${SP}_longest_ids.txt > ${SP}_FINAL_proteins.faa
    
    echo "${SP} final protein count: $(wc -l < ${SP}_longest_ids.txt)"
done

echo "=========================================================="
echo "All protein datasets are ready for OrthoFinder analysis."
echo "=========================================================="
