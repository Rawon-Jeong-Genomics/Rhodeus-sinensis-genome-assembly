#!/usr/bin/env Rscript
# Description: Filtering of false-positive GO terms and generation of Figure 5 (Dot plots)
# Journal: G3: Genes, Genomes, Genetics (Genome Report)
# Software: ggplot2, patchwork

# [Step 1] Load Required Packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, readxl, patchwork)

# ==============================================================================
# [Step 2] Data Loading and Artifact Filtering
# ==============================================================================
# Load REVIGO-processed data (skip the first row if it contains a table title)
supp_data <- read_excel("Jeong_et_al_G3_revised_supplementary_table_S4.xlsx", skip = 1)

# Define keywords for non-vertebrate/invertebrate specific artifacts to exclude
invertebrate_keywords <- c("cuticle", "chitin", "molt", "pupat", "instar", 
                           "ecdyson", "nematod", "arthropod", "insect", 
                           "imaginal", "ommatidium", "ecdysis", "hemolymph",
                           "eclosion", "proboscis", "dorsal closure", "jump", "wing", 
                           "pyrethroid", "pseudocleavage", "compartment", "midgut", "cell wall",
                           "leading edge", "catagen")

# Clean data and calculate numeric GeneRatio
clean_data <- supp_data %>%
  dplyr::mutate(
    GeneRatio_num = as.numeric(sub("/.*", "", GeneRatio)) / as.numeric(sub(".*/", "", GeneRatio)),
    Description = name # Override original description with REVIGO representative name
  ) %>%
  # Filter out artifact rows based on invertebrate keywords
  dplyr::filter(!stringr::str_detect(tolower(Description), paste(invertebrate_keywords, collapse = "|")))

# Save the rigorously cleaned data for Supplementary Table S4
write.csv(clean_data, "Cleaned_Supplementary_Table_S4.csv", row.names = FALSE)

# ==============================================================================
# [Step 3] Data Extraction for Visualization (Figure 5)
# ==============================================================================
# Extract Top 30 (broad, high-frequency concepts) and Low 30 (specific, low-frequency concepts)
top30_data <- clean_data %>% dplyr::arrange(desc(frequency)) %>% head(30)
low30_data <- clean_data %>% dplyr::arrange(frequency) %>% head(30)

# ==============================================================================
# [Step 4] Plotting Function and Figure Generation
# ==============================================================================
# Define a standard dot plot function
plot_dot <- function(data, title) {
  ggplot(data, aes(x = GeneRatio_num, y = reorder(Description, GeneRatio_num))) +
    geom_point(aes(size = Count, color = p.adjust)) +
    scale_color_viridis_c(guide = guide_colorbar(reverse = TRUE)) +
    labs(
      title = title,
      x = "Gene Ratio", 
      y = "", 
      color = "p.adjust", 
      size = "Count"
    ) +
    theme_bw() +
    theme(
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      axis.text.y = element_text(size = 10, color = "black"),
      axis.title = element_text(size = 12, face = "bold"),
      panel.grid.major.y = element_line(color = "grey95")
    )
}

# Generate individual plots
p_high <- plot_dot(top30_data, "Top 30 Broad Concepts")
p_low  <- plot_dot(low30_data, "Top 30 Specific Concepts")

# Combine plots horizontally (Panel A and B)
combined_plot <- (p_high | p_low) + plot_annotation(tag_levels = 'A')

# Save high-resolution PDF for publication
ggsave("Figure5_GO_Enrichment_Dotplots.pdf", plot = combined_plot, width = 17, height = 9, units = "in")
cat("✅ Figure 5 generated and cleaned Supplementary Table S4 saved successfully.\n")
