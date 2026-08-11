#!/usr/bin/env Rscript
# Description: Custom GO Enrichment analysis using clusterProfiler integrating eggNOG and InterProScan
# Journal: G3: Genes, Genomes, Genetics (Genome Report)

# [Step 0] Load Required Packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, clusterProfiler, GO.db)

# ==============================================================================
# [Step 1] Construct Custom Background (TERM2GENE) integrating eggNOG & InterPro
# ==============================================================================
# 1.1 Parse eggNOG annotations
emapper <- read_delim("Rhsi_eggnog.emapper.annotations", delim = "\t", comment = "#", col_names = FALSE)
term2gene_eggnog <- emapper %>%
  dplyr::select(Gene = X1, GO = X10) %>%
  filter(!is.na(GO) & GO != "-") %>%
  separate_rows(GO, sep = ",") %>%
  distinct()

# 1.2 Parse InterProScan annotations
interpro <- read.delim("braker_Rhsi_final_clean_no_star.aa.tsv", header = FALSE, sep = "\t", quote = "")
term2gene_interpro <- interpro %>%
  dplyr::select(Gene = V1, GO = V14) %>%
  filter(!is.na(GO), GO != "") %>%
  separate_rows(GO, sep = "\\|") %>%
  mutate(GO = sub("\\(.*\\)", "", GO)) %>%
  distinct()

# 1.3 Create Consensus TERM2GENE (Genes annotated by BOTH databases for strictness)
term2gene_consensus <- inner_join(term2gene_eggnog, term2gene_interpro, by = c("Gene", "GO"))

# 1.4 Generate TERM2NAME and Ontology matching tables
unique_go_ids <- unique(term2gene_consensus$GO)
go_info <- suppressMessages(AnnotationDbi::select(GO.db, keys = unique_go_ids, columns = c("TERM", "ONTOLOGY"), keytype = "GOID"))
term2name <- go_info %>% dplyr::select(GO = GOID, Description = TERM)
term2ontology <- go_info %>% dplyr::select(GO = GOID, Ontology = ONTOLOGY)

# ==============================================================================
# [Step 2] Perform GO Enrichment Analysis (Expanded & Contracted Genes)
# ==============================================================================
# Statistical thresholds
PVAL_CUTOFF <- 0.01
QVAL_CUTOFF <- 0.05
UNIVERSE_GENES <- unique(term2gene_consensus$Gene)

# 2.1 Function for Enrichment and Export
run_enrichment <- function(gene_list_file, output_prefix) {
  target_genes <- readLines(gene_list_file)
  
  enrich_res <- enricher(
    gene = target_genes,
    universe = UNIVERSE_GENES,
    TERM2GENE = term2gene_consensus,
    TERM2NAME = term2name,
    pvalueCutoff = PVAL_CUTOFF,
    qvalueCutoff = QVAL_CUTOFF,
    pAdjustMethod = "BH"
  )
  
  if (!is.null(enrich_res) && nrow(as.data.frame(enrich_res)) > 0) {
    result_df <- as.data.frame(enrich_res) %>%
      left_join(term2ontology, by = c("ID" = "GO")) %>%
      dplyr::select(Ontology, ID, Description, everything()) %>%
      arrange(p.adjust)
    
    # Save Full Table for Supplementary
    write_csv(result_df, paste0(output_prefix, "_Full.csv"))
    # Save Simple Table for REVIGO
    result_df %>% dplyr::select(ID, p.adjust) %>% write_csv(paste0(output_prefix, "_simple.csv"))
    
    cat("✅ Enrichment complete for", output_prefix, "| Found:", nrow(result_df), "terms.\n")
  } else {
    cat("⚠️ No significant GO terms found for", output_prefix, "\n")
  }
}

# 2.2 Run for Expanded and Contracted gene families
run_enrichment("Rhodeus_sinensis_expanded_genes.txt", "Rhodeus_GO_expanded")
run_enrichment("Rhodeus_sinensis_contracted_genes.txt", "Rhodeus_GO_contracted")
