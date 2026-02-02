#!/bin/bash
# Description: Phylogenetic reconstruction and chronogram conversion
# Software: IQ-TREE v1.5.5, R (Ape package v5.7-1)
# Reference: Paradis and Schliep 2019; Nguyen et al. 2015

# 1. IQ-TREE Reconstruction
echo "=========================================================="
echo "Step 1: Maximum-Likelihood Tree Reconstruction (IQ-TREE)"
echo "=========================================================="
# -s: input alignment, -m: model selection (MFP), -bb: UFBoot (1000)
# Output: concatenated_alignment.phy.treefile
iqtree -s concatenated_alignment.phy -m MFP -bb 1000 -alrt 1000 -nt AUTO

echo "=========================================================="
echo "Step 2: Converting to Ultrametric Chronogram in R"
echo "=========================================================="

# 2. Running R script for Chronos Calibration
Rscript - <<'EOF'
library(ape)

# 1. Load the Tree (Using the standardized output name from IQ-TREE)
# Replace 'concatenated_alignment.phy.treefile' with your actual result path
phy <- read.tree("concatenated_alignment.phy.treefile")

# 2. Define MRCA Nodes for Calibration (Fossil-based)
Clu <- getMRCA(phy, c("Esox_lucius.fEsoLuc1.pri.pep.all", "Clupea_harengus.Ch_v2.0.2v2.pep.all")) 
Oto <- getMRCA(phy, c("Clupea_harengus.Ch_v2.0.2v2.pep.all","Danio_rerio.GRCz11.pep.all"))
Oto2 <- getMRCA(phy, c("Danio_rerio.GRCz11.pep.all", "Electrophorus_electricus.fEleEle1.pri.pep.all"))
Cha <- getMRCA(phy, c("Electrophorus_electricus.fEleEle1.pri.pep.all", "Pygocentrus_nattereri.fPygNat1.pri.pep.all"))

# 3. Set Calibration Points (Million Years Ago)
calibs <- makeChronosCalib(phy,
                           node = c(Clu, Oto, Oto2, Cha),
                           age.min = c(250, 230, 180, 150),
                           age.max = c(250, 230, 180, 150))

# 4. Chronogram Estimation (chronos function)
time_tree <- chronos(phy, calibration = calibs)

# 5. Validation and Export
if(is.ultrametric(time_tree)) {
    write.tree(time_tree, file = "ultrametric_tree_for_cafe.nwk")
    cat("Ultrametric tree has been successfully saved for CAFÉ5 analysis.\n")
} else {
    cat("Warning: The generated tree is NOT ultrametric.\n")
}
EOF

echo "=========================================================="
echo "Phylogenetic analysis and chronogram conversion complete."
echo "=========================================================="
