#!/bin/bash
# Description: Orthologous gene family identification and multiple sequence alignment
# Journal: G3: Genes, Genomes, Genetics (Genome Report)
# Software: OrthoFinder

echo "=========================================================="
echo "Running OrthoFinder"
echo "=========================================================="
# '-f ./' assumes you are running this in the directory containing your 11 .faa protein files
# FastTree is used for initial tree inference (-T fasttree)
orthofinder -f ./ -S diamond -M msa -T fasttree -t 24 -a 24

echo "=========================================================="
echo "OrthoFinder complete. SpeciesTreeAlignment.fa generated."
echo "=========================================================="
