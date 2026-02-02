# Rhodeus-sinensis-genome-assembly
Genome assembly pipeline and scripts for Rhodeus sinensis, submitted as a Genome Report to G3: Genes, Genomes, Genetics.

This repository contains the bioinformatic pipelines and key annotation datasets for the chromosome-level genome assembly of the rosy bitterling, Rhodeus sinensis.

## Project Overview
The study provides a high-quality reference genome of R. sinensis to investigate its evolutionary history, including chromosomal evolution (synteny) and gene family dynamics (expansion/contraction) within the Cypriniformes order.

---

## Repository Structure

### scripts/
- 01_Assembly/: Genome assembly via PacBio HiFi and Hi-C scaffolding (Juicebox, 3D-DNA).
- 02_Annotation/: Repeat masking, gene prediction (EVM), and functional annotation.
- 03_Synteny/: Chromosomal synteny analysis against D. rerio using MCScanX and D-GENIES.
- 04_Phylogenomics/: OrthoFinder inference, IQ-TREE phylogeny, and CAFE5 gene family analysis.

### data/
- data/annotation/rs_final_annotation.gff3.gz: Final curated gene models for R. sinensis.

---

## Data Availability

### Genome Assembly & Accession
The Whole Genome Shotgun project for Rhodeus sinensis has been deposited at DDBJ/ENA/GenBank under the accession JBPQOI000000000. 
- Current Version described in this paper: JBPQOI010000000

### NCBI BioProject & BioSample
- BioProject: PRJNA1237734
- BioSample: SAMN47434658

### Raw Sequencing Data (SRA Accessions)
All raw sequencing data are available in the NCBI Sequence Read Archive (SRA) under the following accessions:

| Platform | Data Type | SRA Accession |
| :--- | :--- | :--- |
| Illumina | Short reads | SRR36863532 |
| PacBio | HiFi long reads | SRR36863529, SRR36863530, SRR36863531 |
| Hi-C | Interaction reads | SRR36863528 |
| RNA-seq | Transcriptome data | SRR36863527 |

---

## Usage
1. Clone the repository:
   git clone https://github.com/Rawon-Jeong-Genomics/Rhodeus-sinensis-genome-assembly.git

2. Analysis: Scripts are located in the scripts/ directory. Please refer to each script for specific parameters and input requirements.

---

## Citation
If you use the data or scripts from this repository, please cite:
Jeong et al. (2026). Chromosome-level genome assembly of a bitterling species, Rhodeus sinensis (Acheilognathidae), provides insights into genomic adaptations to a mussel-dependent reproductive system. (In preparation).
---

## Contact
Rawon Jeong - jrw8882@gmail.com
Department of Life Sciences, Yeungnam University, Gyeongsan, Republic of Korea
