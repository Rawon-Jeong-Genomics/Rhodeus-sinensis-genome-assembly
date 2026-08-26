#!/usr/bin/env Rscript
# ==============================================================================
# Description: Filtering of false-positive GO terms and generation of Dot plots
# Software: R, ggplot2, patchwork, tidyverse, readxl
# ==============================================================================

# ==============================================================================
# Input variables (Modify these according to your environment)
# ==============================================================================
# 1. Input/Output Files
INPUT_EXCEL <- "revigo_processed_data.xlsx"
OUTPUT_CSV <- "Cleaned_GO_results.csv"
OUTPUT_PDF <- "GO_Enrichment_Dotplots.pdf"

# 2. Filtering parameters
# Define keywords for non-target artifacts to exclude.
# The current list filters out insect/invertebrate terms (useful for vertebrate studies).
EXCLUDE_KEYWORDS <- c("cuticle", "chitin", "molt", "pupat", "instar", 
                      "ecdyson", "nematod", "arthropod", "insect", 
                      "imaginal", "ommatidium", "ecdysis", "hemolymph",
                      "eclosion", "proboscis", "dorsal closure", "jump", "wing", 
                      "pyrethroid", "pseudocleavage", "compartment", "midgut", "cell wall",
                      "leading edge", "catagen")

# 3. Plotting parameters
TOP_N <- 30 # Number of top and low terms to plot
# ==============================================================================

# [Step 1] Load Required Packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, readxl, patchwork)

# ==============================================================================
# [Step 2] Data Loading and Artifact Filtering
# ==============================================================================
cat("Step 1: Loading REVIGO-processed data and filtering artifacts...\n")

# Load data (skip the first row if it contains a table title)
if (!file.exists(INPUT_EXCEL)) {
  stop(paste("⚠️ Input file not found:", INPUT_EXCEL))
}
supp_data <- read_excel(INPUT_EXCEL, skip = 1)

# Clean data and calculate numeric GeneRatio
clean_data <- supp_data %>%
  dplyr::mutate(
    GeneRatio_num = as.numeric(sub("/.*", "", GeneRatio)) / as.numeric(sub(".*/", "", GeneRatio)),
    Description = name # Override original description with REVIGO representative name
  ) %>%
  # Filter out artifact rows based on exclude keywords
  dplyr::filter(!stringr::str_detect(tolower(Description), paste(EXCLUDE_KEYWORDS, collapse = "|")))

# Save the rigorously cleaned data
write.csv(clean_data, OUTPUT_CSV, row.names = FALSE)

# ==============================================================================
# [Step 3] Data Extraction for Visualization
# ==============================================================================
cat("Step 2: Extracting Top and Low concepts for visualization...\n")

# Extract Top N (broad, high-frequency concepts) and Low N (specific, low-frequency concepts)
top_n_data <- clean_data %>% dplyr::arrange(desc(frequency)) %>% head(TOP_N)
low_n_data <- clean_data %>% dplyr::arrange(frequency) %>% head(TOP_N)

# ==============================================================================
# [Step 4] Plotting Function and Figure Generation
# ==============================================================================
cat("Step 3: Generating dot plots...\n")

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
p_high <- plot_dot(top_n_data, paste("Top", TOP_N, "Broad Concepts"))
p_low  <- plot_dot(low_n_data, paste("Top", TOP_N, "Specific Concepts"))

# Combine plots horizontally (Panel A and B)
combined_plot <- (p_high | p_low) + plot_annotation(tag_levels = 'A')

# Save high-resolution PDF for publication
ggsave(OUTPUT_PDF, plot = combined_plot, width = 17, height = 9, units = "in")

cat("==========================================================\n")
cat("✅ Dot plots generated and cleaned data saved successfully.\n")
cat("==========================================================\n")
