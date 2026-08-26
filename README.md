# Rhodeus-sinensis-genome-assembly

Genome assembly pipeline and scripts for *Rhodeus sinensis*, submitted to *G3: Genes, Genomes, Genetics*.

## Project Overview

This repository contains the computational pipeline, scripts, and genomic resources for the high-quality, chromosome-level genome assembly of the bitterling *Rhodeus sinensis*.

---

## Genome Assembly Highlights

We integrated PacBio CLR, Illumina short reads, and Hi-C sequencing technologies to achieve a highly contiguous reference genome:
* **Assembly Size:** 0.77 Gb
* **Contiguity:** Scaffold N50 of 30.06 Mb
* **Completeness:** 96.3% BUSCO score (`Actinopterygii_odb10`)
* **Scaffolding:** 24 chromosome-scale scaffolds, representing 98.3% of the total assembly.

---

## Repository Structure

`scripts/`
* **`01_Assembly/`**: Hybrid genome assembly using PacBio CLR and Illumina reads (HASLR), followed by Hi-C scaffolding (Juicer, 3D-DNA) and manual curation (Juicebox).
* **`02_Annotation/`**: Repeat masking (RepeatModeler2, RepeatMasker), gene prediction integrating RNA-seq and protein evidence (BRAKER3, TSEBRA), redundancy reduction (AGAT), and functional annotation (Swiss-Prot via Diamond, eggNOG-mapper, InterProScan).
* **`03_Synteny/`**: Macro-synteny and chromosomal rearrangement analysis among cyprinid lineages using MCScan (JCVI utility libraries).
* **`04_Phylogenomics/`**: Orthologous gene family identification (OrthoFinder), phylogenetic reconstruction (IQ-TREE, MCMCTREE), and gene family expansion/contraction analysis (CAFE5).

---

## Data Availability

All raw data and the final genome assembly have been deposited in public databases.

### Genome Assembly & Accession
* **Whole Genome Shotgun project:** Deposited at DDBJ/ENA/GenBank under the accession `JBPQOI000000000`.
* **Version described in this paper:** `JBPQOI010000000`.

### NCBI BioProject & BioSample
* **BioProject:** `PRJNA1237734`
* **BioSample:** `SAMN47434658`

### Raw Sequencing Data (SRA Accessions)

| Platform | Data Type | SRA Accession |
| :--- | :--- | :--- |
| Illumina | Short reads | `SRR36863532` |
| PacBio | CLR long reads | `SRR36863529`, `SRR36863530`, `SRR36863531` |
| Hi-C | Interaction reads | `SRR36863528` |
| Illumina | Transcriptome data (RNA-seq) | `SRR36863527` |

---

## Citation

If you use the data, genome assembly, or scripts from this repository, please cite:
> Jeong R, Kim J, Suk HY. (2026). Chromosome-level genome assembly of the bitterling *Rhodeus sinensis* (Acheilognathidae) reveals genomic signatures associated with its mussel-dependent reproductive system. *Submitted to G3: Genes, Genomes, Genetics*.
