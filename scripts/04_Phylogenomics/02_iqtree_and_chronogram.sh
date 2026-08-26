#!/bin/bash
# ==============================================================================
# Description: Maximum likelihood phylogeny and divergence time estimation
# Software: IQ-TREE v2.2.6, PAML (MCMCTREE) v4.10.9
# ==============================================================================

# ==============================================================================
# Input variables (Modify these according to your environment)
# ==============================================================================
# 1. Input/Output Files
ALIGNMENT_FA="SpeciesTreeAlignment.fa"  # FASTA alignment (e.g., from OrthoFinder)
ALIGNMENT_PHY="alignment.phy"           # PHYLIP format alignment for MCMCTREE
TREE="mcmctree_input.nwk"               # Input tree with fossil calibrations
CTL_STEP1="mcmctree_step1.ctl"
CTL_STEP2="mcmctree_step2.ctl"

# 2. Hardware and MCMC Parameters
THREADS=16
# Define the maximum root age (e.g., '<3.0' means max 300 MYA)
ROOT_AGE="<3.0" 

# ==============================================================================
# Run Analysis
# ==============================================================================

echo "=========================================================="
echo "Step 1: Maximum Likelihood Tree Reconstruction (IQ-TREE2)"
echo "=========================================================="
# SH-aLRT and UFBoot with 1000 replicates using ModelFinder (MFP)
iqtree2 -s $ALIGNMENT_FA \
        -m MFP \
        --alrt 1000 \
        -B 1000 \
        -nt $THREADS

echo "=========================================================="
echo "Step 2: Generating MCMCTREE Control Files (PAML)"
echo "=========================================================="
# Generating Control File for Step 1 (Calculate Hessian Matrix)
cat <<EOF > $CTL_STEP1
seed = -1
seqfile = $ALIGNMENT_PHY
treefile = $TREE
mcmcfile = mcmc.txt
outfile = out.txt

ndata = 1
seqtype = 2        * 2: Amino Acids
usedata = 3        * 3: Calculate Hessian Matrix (in.BV)
clock = 2          * 2: Independent rates (Relaxed clock)
RootAge = '$ROOT_AGE'  * Max root age bound

model = 2          * 2: Empirical substitution model (WAG)
aaRatefile = wag.dat

alpha = 0.5        * alpha for gamma rates at sites
ncatG = 5          * No. categories in discrete gamma
cleandata = 0      * Ambiguous characters masked as gaps

BDparas = 1 1 0.1 C
alpha_gamma = 1 1      

rgene_gamma = 2 13 1   
sigma2_gamma = 1 10 1  

finetune = 1: .1 .1 .1 .1 .1 .1
print = 1
burnin = 20000
sampfreq = 50
nsample = 200000
EOF

# Generating Control File for Step 2 (Actual MCMC Sampling)
cat <<EOF > $CTL_STEP2
seed = 3
seqfile = $ALIGNMENT_PHY
treefile = $TREE
mcmcfile = mcmc.txt
outfile = mcmctree_log.txt

ndata = 1
seqtype = 2        * 2: Amino Acids
usedata = 2        * 2: Use in.BV for MCMC sampling
clock = 2          * 2: Independent rates (Relaxed clock)
RootAge = '$ROOT_AGE'  * Max root age bound

model = 2          * 2: Empirical substitution model (WAG)
aaRatefile = wag.dat

alpha = 0.5        * alpha for gamma rates at sites
ncatG = 5          * No. categories in discrete gamma
cleandata = 0      * Ambiguous characters masked as gaps

BDparas = 1 1 0.1 C
alpha_gamma = 1 1      

rgene_gamma = 2 13 1   
sigma2_gamma = 1 10 1  

finetune = 1: .1 .1 .1 .1 .1 .1
print = 1
burnin = 50000
sampfreq = 100
nsample = 500000
EOF

echo "=========================================================="
echo "Step 3: Approximate Likelihood - Step 1 (Calculate Hessian)"
echo "=========================================================="
mcmctree $CTL_STEP1

# Run codeml to generate in.BV (Hessian matrix)
cp tmp0001.ctl codeml.ctl
codeml codeml.ctl
mv rst2 in.BV

echo "=========================================================="
echo "Step 4: Approximate Likelihood - Step 2 (MCMC Sampling)"
echo "=========================================================="
mcmctree $CTL_STEP2

echo "=========================================================="
echo "MCMCTREE run complete."
echo "Check 'mcmctree_log.txt' and 'FigTree.tre'."
echo "=========================================================="
#!/bin/bash
# ==============================================================================
# Description: Maximum likelihood phylogeny and divergence time estimation
# Software: IQ-TREE v2.2.6, PAML (MCMCTREE) v4.10.9
# ==============================================================================

# ==============================================================================
# Input variables (Modify these according to your environment)
# ==============================================================================
# 1. Input/Output Files
ALIGNMENT_FA="SpeciesTreeAlignment.fa"  # FASTA alignment (e.g., from OrthoFinder)
ALIGNMENT_PHY="alignment.phy"           # PHYLIP format alignment for MCMCTREE
TREE="mcmctree_input.nwk"               # Input tree with fossil calibrations
CTL_STEP1="mcmctree_step1.ctl"
CTL_STEP2="mcmctree_step2.ctl"

# 2. Hardware and MCMC Parameters
THREADS=16
# Define the maximum root age (e.g., '<3.0' means max 300 MYA)
ROOT_AGE="<3.0" 

# ==============================================================================
# Run Analysis
# ==============================================================================

echo "=========================================================="
echo "Step 1: Maximum Likelihood Tree Reconstruction (IQ-TREE2)"
echo "=========================================================="
# SH-aLRT and UFBoot with 1000 replicates using ModelFinder (MFP)
iqtree2 -s $ALIGNMENT_FA \
        -m MFP \
        --alrt 1000 \
        -B 1000 \
        -nt $THREADS

echo "=========================================================="
echo "Step 2: Generating MCMCTREE Control Files (PAML)"
echo "=========================================================="
# Generating Control File for Step 1 (Calculate Hessian Matrix)
cat <<EOF > $CTL_STEP1
seed = -1
seqfile = $ALIGNMENT_PHY
treefile = $TREE
mcmcfile = mcmc.txt
outfile = out.txt

ndata = 1
seqtype = 2        * 2: Amino Acids
usedata = 3        * 3: Calculate Hessian Matrix (in.BV)
clock = 2          * 2: Independent rates (Relaxed clock)
RootAge = '$ROOT_AGE'  * Max root age bound

model = 2          * 2: Empirical substitution model (WAG)
aaRatefile = wag.dat

alpha = 0.5        * alpha for gamma rates at sites
ncatG = 5          * No. categories in discrete gamma
cleandata = 0      * Ambiguous characters masked as gaps

BDparas = 1 1 0.1 C
alpha_gamma = 1 1      

rgene_gamma = 2 13 1   
sigma2_gamma = 1 10 1  

finetune = 1: .1 .1 .1 .1 .1 .1
print = 1
burnin = 20000
sampfreq = 50
nsample = 200000
EOF

# Generating Control File for Step 2 (Actual MCMC Sampling)
cat <<EOF > $CTL_STEP2
seed = 3
seqfile = $ALIGNMENT_PHY
treefile = $TREE
mcmcfile = mcmc.txt
outfile = mcmctree_log.txt

ndata = 1
seqtype = 2        * 2: Amino Acids
usedata = 2        * 2: Use in.BV for MCMC sampling
clock = 2          * 2: Independent rates (Relaxed clock)
RootAge = '$ROOT_AGE'  * Max root age bound

model = 2          * 2: Empirical substitution model (WAG)
aaRatefile = wag.dat

alpha = 0.5        * alpha for gamma rates at sites
ncatG = 5          * No. categories in discrete gamma
cleandata = 0      * Ambiguous characters masked as gaps

BDparas = 1 1 0.1 C
alpha_gamma = 1 1      

rgene_gamma = 2 13 1   
sigma2_gamma = 1 10 1  

finetune = 1: .1 .1 .1 .1 .1 .1
print = 1
burnin = 50000
sampfreq = 100
nsample = 500000
EOF

echo "=========================================================="
echo "Step 3: Approximate Likelihood - Step 1 (Calculate Hessian)"
echo "=========================================================="
mcmctree $CTL_STEP1

# Run codeml to generate in.BV (Hessian matrix)
cp tmp0001.ctl codeml.ctl
codeml codeml.ctl
mv rst2 in.BV

echo "=========================================================="
echo "Step 4: Approximate Likelihood - Step 2 (MCMC Sampling)"
echo "=========================================================="
mcmctree $CTL_STEP2

echo "=========================================================="
echo "MCMCTREE run complete."
echo "Check 'mcmctree_log.txt' and 'FigTree.tre'."
echo "=========================================================="
