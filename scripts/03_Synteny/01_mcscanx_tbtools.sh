#!/bin/bash
# Description: Synteny analysis between R. sinensis and D. rerio
# Software: MCScanX (implemented in TBtools v1.112)
# Reference: Wang et al. 2012; Chen et al. 2020

echo "=========================================================="
echo "Synteny Analysis Procedure via TBtools (MCScanX)"
echo "=========================================================="
echo "Step 1: Data Preparation"
echo "  - Genome A: R. sinensis (Query)"
echo "  - Genome B: D. rerio (Reference, 2n=50)"
echo "  - Input files: Protein sequences (.fasta) and Gene location (.gff3)"
echo ""
echo "Step 2: Reciprocal BLASTP"
echo "  - Tool: TBtools Built-in BLASTP"
echo "  - E-value: 1e-5"
echo ""
echo "Step 3: Identification of Syntenic Blocks (MCScanX)"
echo "  - Method: 'One Step MCScanX' in TBtools"
echo "  - Minimum block size: 15 (Set to 15 for a more conservative analysis)"
echo "    * Higher values filter out small fragmented alignments."
echo "=========================================================="
