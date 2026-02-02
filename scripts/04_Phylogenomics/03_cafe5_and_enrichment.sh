#!/bin/bash
# Software: CAFÉ5, R (topGO, clusterProfiler, ggplot2)
# Goal: Gene family evolution and functional enrichment visualization

# 1. CAFÉ5 Analysis
echo "=========================================================="
echo "Step 1: Running CAFÉ5 for Gene Family Evolution"
echo "=========================================================="
# -t: Ultrametric tree from previous step
# -f: Gene family count table (standardized name)
cafe5 -t ultrametric_tree.nwk -f gene_family_counts.txt -p

echo "=========================================================="
echo "Step 2: Functional Enrichment and Visualization in R"
echo "=========================================================="

# 2. Running R script
Rscript - <<'EOF'
library(topGO)
library(dplyr)
library(ggplot2)
library(viridis)
library(forcats)
library(graph)

# --- 1. Load Data ---
# Standardized filenames for reproducibility
geneID2GO <- readMappings("gene2go_mapping.txt")
allGenes <- names(geneID2GO)

expandedGenes <- scan("significant_expanded_genes.txt", what = "", sep = "\n")
contractedGenes <- scan("significant_contracted_genes.txt", what = "", sep = "\n")

# --- 2. GO Analysis Function ---
createGeneList <- function(sigGenes, allGenes) {
  geneList <- factor(as.integer(allGenes %in% sigGenes))
  names(geneList) <- allGenes
  return(geneList)
}

run_GO <- function(geneList, geneID2GO, ont, FDR_cutoff = 0.01) {
  GOdata <- new("topGOdata", ontology = ont, allGenes = geneList,
                annot = annFUN.gene2GO, gene2GO = geneID2GO)
  
  result <- runTest(GOdata, algorithm = "classic", statistic = "fisher")
  nNodes <- length(graph::nodes(graph(GOdata)))
  table <- GenTable(GOdata, classicFisher = result, topNodes = nNodes)
  
  table$classicFisher <- as.numeric(gsub("< ", "", table$classicFisher))
  table <- table[!is.na(table$classicFisher), ]
  table$FDR <- p.adjust(table$classicFisher, method = "BH") # BH correction
  
  table_sig <- table[table$FDR < FDR_cutoff, ]
  if(nrow(table_sig) > 0) {
    table_sig$negLog10FDR <- -log10(table_sig$FDR)
    table_sig$Category <- ont
  }
  return(table_sig)
}

# --- 3. Execute Enrichment ---
ontologies <- c("BP", "CC", "MF")
GO_exp_list <- lapply(ontologies, function(o) run_GO(createGeneList(expandedGenes, allGenes), geneID2GO, o))
GO_con_list <- lapply(ontologies, function(o) run_GO(createGeneList(contractedGenes, allGenes), geneID2GO, o))

GO_exp <- bind_rows(GO_exp_list) %>% mutate(Group = "Expansion")
GO_con <- bind_rows(GO_con_list) %>% mutate(Group = "Contraction")
GO_all <- bind_rows(GO_exp, GO_con)

# Save results
write.csv(GO_all, "GO_enrichment_results_FDR0.01.csv", row.names = FALSE)

# --- 4. Visualization (Dot Plot) ---
# Select Top 10 terms per group
GO_top <- GO_all %>%
  group_by(Category, Group) %>%
  arrange(FDR) %>%
  slice_head(n = 10) %>%
  ungroup() %>%
  mutate(Term = fct_reorder(Term, negLog10FDR))

ggplot(GO_top, aes(x = negLog10FDR, y = Term, size = Significant, color = negLog10FDR)) +
  geom_point(aes(shape = Group), position = position_jitterdodge(jitter.width = 0.2, dodge.width = 0.6)) +
  scale_shape_manual(values = c("Expansion" = 16, "Contraction" = 17)) +
  scale_color_viridis(option = "D") +
  facet_wrap(~ Category, scales = "free_y") +
  labs(x = "-log10(FDR)", y = "GO Term", size = "Gene count", shape = "Group",
       title = "Top GO terms for Expansion vs Contraction (FDR < 0.01)") +
  theme_bw() +
  theme(axis.text.y = element_text(size = 9),
        strip.background = element_rect(fill = "lightgray"),
        strip.text = element_text(size = 12))

ggsave("GO_enrichment_dotplot.pdf", width = 10, height = 8)
EOF

echo "=========================================================="
echo "CAFÉ5 and GO Enrichment Analysis Complete."
echo "=========================================================="
