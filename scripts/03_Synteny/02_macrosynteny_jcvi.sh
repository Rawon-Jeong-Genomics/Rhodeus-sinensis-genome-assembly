#!/bin/bash
# Description: Macro-synteny and chromosomal rearrangement analysis
# Journal: G3: Genes, Genomes, Genetics (Genome Report)
# Software: JCVI utility libraries v1.6.5, LAST v1651

echo "=========================================================="
echo "Step 1: Format preparation (GFF to BED)"
echo "=========================================================="
# Convert GFF3 files to BED format for structural analysis
# (Make sure Rhodeus_sinensis.pep, Danio_rerio.pep, Ctenopharyngodon_idella.pep exist)
python -m jcvi.formats.gff bed --type=mRNA --key=ID Rhodeus_sinensis.gff > Rhodeus_sinensis.bed
python -m jcvi.formats.gff bed --type=mRNA --key=ID Danio_rerio.gff > Danio_rerio.bed
python -m jcvi.formats.gff bed --type=mRNA --key=ID Ctenopharyngodon_idella.gff > Ctenopharyngodon_idella.bed

echo "=========================================================="
echo "Step 2: Pairwise Ortholog Search using LAST"
echo "=========================================================="
# All-against-all local alignments using LAST aligner
python -m jcvi.compara.catalog ortholog Rhodeus_sinensis Danio_rerio --aligner=last --no_strip_names
python -m jcvi.compara.catalog ortholog Rhodeus_sinensis Ctenopharyngodon_idella --aligner=last --no_strip_names

echo "=========================================================="
echo "Step 3: Synteny Block Filtering"
echo "=========================================================="
# Rigorously filter synteny blocks (minimum 30 consecutive pairs, simple paths)
python -m jcvi.compara.synteny screen --minspan=30 --simple Rhodeus_sinensis.Danio_rerio.anchors Rhodeus_sinensis.Danio_rerio.anchors.new
python -m jcvi.compara.synteny screen --minspan=30 --simple Rhodeus_sinensis.Ctenopharyngodon_idella.anchors Rhodeus_sinensis.Ctenopharyngodon_idella.anchors.new

echo "=========================================================="
echo "Step 4: Karyotype Visualization"
echo "=========================================================="
# Generate Karyotype plot (Requires 'seqids' and 'layout' configuration files)
python -m jcvi.graphics.karyotype seqids layout
