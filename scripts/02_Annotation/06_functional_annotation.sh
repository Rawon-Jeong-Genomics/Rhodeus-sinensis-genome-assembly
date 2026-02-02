#!/bin/bash
# Description: Functional annotation with best-hit filtering for each database
# Journal: G3: Genes, Genomes, Genetics (Genome Report)
# Software: BLASTP v2.10.0+, InterProScan v5.41-78.0

# 1. Path and Parameter Definition
QUERY_PROTEIN="rs_final_gene_models.evm.pep"
THREADS=32
E_VALUE="1e-5"

echo "=========================================================="
echo "Step 1: Functional search with Best-Hit Filtering"
echo "=========================================================="

# 1.1 NCBI Nr
echo "Running BLASTP against NCBI Nr..."
blastp -query $QUERY_PROTEIN -db nr -out rs_blastp_nr_full.out \
       -evalue $E_VALUE -num_threads $THREADS -outfmt 6
# Keep only the first hit (best hit) for each query
awk '!seen[$1]++' rs_blastp_nr_full.out > rs_blastp_nr.out

# 1.2 Swiss-Prot
echo "Running BLASTP against Swiss-Prot..."
blastp -query $QUERY_PROTEIN -db swissprot -out rs_blastp_swissprot_full.out \
       -evalue $E_VALUE -num_threads $THREADS -outfmt 6
awk '!seen[$1]++' rs_blastp_swissprot_full.out > rs_blastp_swissprot.out

# 1.3 RefSeq
echo "Running BLASTP against RefSeq..."
blastp -query $QUERY_PROTEIN -db refseq_protein -out rs_blastp_refseq_full.out \
       -evalue $E_VALUE -num_threads $THREADS -outfmt 6
awk '!seen[$1]++' rs_blastp_refseq_full.out > rs_blastp_refseq.out

echo "=========================================================="
echo "Step 2: Domain, GO, and Pathway annotation"
echo "=========================================================="
# InterProScan for Pfam domains and GO terms
interproscan.sh -i $QUERY_PROTEIN \
                -f TSV,GFF3 \
                -goterms -pa \
                -cpu $THREADS \
                -o rs_interproscan_results

# Cleanup: Optional to remove large full output files
# rm *_full.out

echo "=========================================================="
echo "Functional annotation complete."
echo "Best hits are saved in rs_blastp_*.out"
echo "=========================================================="
