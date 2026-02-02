#!/bin/bash
# Description: Genome-wide dot-plot analysis for synteny validation
# Software: D-GENIES (Web-based or Local v1.2.0)
# Reference: Cabanettes and Klopp 2018

echo "=========================================================="
echo "Dot-plot Analysis Procedure via D-GENIES"
echo "=========================================================="
echo "Step 1: Input Data"
echo "  - Target: R. sinensis (Final chromosome-level assembly)"
echo "  - Query: D. rerio (RefSeq assembly)"
echo ""
echo "Step 2: Alignment Tool"
echo "  - Aligner: Minimap2 (Many-to-Many mode)"
echo ""
echo "Step 3: Visualization"
echo "  - Sorting: Sort by synteny to highlight chromosomal relationships"
echo "  - Filter: Noise reduction for clearer chromosomal alignment"
echo "=========================================================="
