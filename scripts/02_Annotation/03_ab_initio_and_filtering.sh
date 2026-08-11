#!/bin/bash
# Description: Gene prediction (BRAKER3), isoform filtering (AGAT), TE removal, and strict functional validation
# Journal: G3: Genes, Genomes, Genetics (Genome Report)
# Software: BRAKER v3.0.8, TSEBRA, AGAT v1.2.0, TEsorter, eggNOG-mapper, DIAMOND, InterProScan, seqtk

THREADS=24
GENOME="Rhodeus_sinensis_genome.fasta.masked"
BAM="star_trimmed_out/Aligned.sortedByCoord.out.bam"
PROT_DB="actinopterygii_odb10/refseq_db.faa"

echo "=========================================================="
echo "Step 1: BRAKER Gene Prediction (Protein & RNA-seq separately)"
echo "=========================================================="
# 1.1 Protein-based prediction
braker.pl --threads=16 --gff3 --softmasking --genome=$GENOME --species=Rhsi_prot --prot_seq=$PROT_DB --workingdir=braker_prot

# 1.2 RNA-based prediction
braker.pl --threads=24 --gff3 --softmasking --genome=$GENOME --species=Rhsi --bam=$BAM --workingdir=braker_rna

echo "=========================================================="
echo "Step 2: Merge predictions and retain longest isoforms (AGAT)"
echo "=========================================================="
# Fix IDs to prevent conflict
sed 's/\([[:space:]"]\)g\([0-9]\)/\1prot_g\2/g' braker_prot/braker.gtf > braker_prot_fixed.gtf
sed 's/\([[:space:]"]\)g\([0-9]\)/\1rna_g\2/g' braker_rna/braker.gtf > braker_rna_fixed.gtf

# Merge and extract longest isoform
agat_sp_merge_annotations.pl -f braker_prot_fixed.gtf -f braker_rna_fixed.gtf -o merged_agat.gff
agat_sp_keep_longest_isoform.pl -gff merged_agat.gff -o final_longest_agat.gff
agat_sp_extract_sequences.pl -g final_longest_agat.gff -f $GENOME -p -o final_longest_agat.aa

echo "=========================================================="
echo "Step 3: Remove TE-related proteins (TEsorter)"
echo "=========================================================="
TEsorter final_longest_agat.aa -p $THREADS -st prot
tail -n +2 final_longest_agat.aa.rexdb.cls.tsv | awk -F '\t' '{print $1}' | sort | uniq > TESORTER_BLACKLIST.txt
grep "^>" final_longest_agat.aa | cut -d ' ' -f 1 | sed 's/>//' | sort | uniq | grep -v -f TESORTER_BLACKLIST.txt > PRE_CLEAN_ids.txt
seqtk subseq final_longest_agat.aa PRE_CLEAN_ids.txt > PRE_CLEAN_proteins.aa

echo "=========================================================="
echo "Step 4: Functional Annotation (eggNOG, Swiss-Prot, InterPro)"
echo "=========================================================="
# 4.1 eggNOG-mapper
emapper.py -i PRE_CLEAN_proteins.aa -o rhodeus_eggnog --cpu $THREADS --itype proteins -m diamond
awk -F '\t' '!/^#/ {print $1}' rhodeus_eggnog.emapper.annotations | sort | uniq > valid_eggnog_ids.txt

# 4.2 Swiss-Prot (DIAMOND)
diamond blastp -q PRE_CLEAN_proteins.aa -d uniprot_sprot -o diamond_swissprot_results.tsv --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore --max-target-seqs 1 --evalue 1e-5 -p $THREADS
awk -F '\t' '{print $1}' diamond_swissprot_results.tsv | sort | uniq > valid_swissprot_ids.txt

# 4.3 InterProScan
interproscan.sh -i PRE_CLEAN_proteins.aa -f tsv -appl Pfam,PANTHER -goterms -pa -dp -cpu $THREADS -d interpro_output
awk -F '\t' '{print $1}' interpro_output/PRE_CLEAN_proteins.aa.tsv | sort | uniq > valid_interpro_ids.txt

echo "=========================================================="
echo "Step 5: Final Strict Validation (>= 2 DB hits)"
echo "=========================================================="
cat valid_eggnog_ids.txt valid_interpro_ids.txt valid_swissprot_ids.txt | sort | uniq -c | awk '$1 >= 2 {print $2}' > STRICT_FINAL_ids.txt

# Extract final strictly validated proteins and GFF
seqtk subseq PRE_CLEAN_proteins.aa STRICT_FINAL_ids.txt > Rhodeus_sinensis_FINAL_proteins.faa
agat_sp_filter_feature_from_keep_list.pl --gff final_longest_agat.gff --keep_list STRICT_FINAL_ids.txt --out Rhodeus_sinensis_FINAL_annotation.gff

echo "Annotation complete. Final high-confidence gene count: $(wc -l < STRICT_FINAL_ids.txt)"
