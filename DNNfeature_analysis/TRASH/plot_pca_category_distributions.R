library(ggplot2)
library(dplyr)
library(tidyr)

plot_pc_distributions <- function(df_pca) {
  # Select only PC columns
  pc_columns <- grep("^PC\\d+$", names(df_pca), value = TRUE)
  
  # Convert to long format for ggplot
  df_long <- df_pca %>%
    select(category, all_of(pc_columns)) %>%
    pivot_longer(cols = all_of(pc_columns), names_to = "PC", values_to = "value")
  
  # Create the plot
  ggplot(df_long, aes(x = value, fill = category)) +
    geom_density(alpha = 0.5) +  # Density plot with transparency
    facet_wrap(~ PC, scales = "free") +  # Separate panel for each PC
    theme_minimal() +
    labs(title = "Distribution of PC Variables by Category",
         x = "PC Value",
         y = "Density") +
    theme(legend.position = "bottom")
}

# Run the function
plot_pc_distributions(df_pca)
