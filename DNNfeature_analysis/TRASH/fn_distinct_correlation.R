fn_distinct_correlation <- function(df_pca, params) {
  
  message("Starting similarity computation...")
  
  # Ensure stimulus is a character to avoid factor issues
  df_pca <- df_pca %>% mutate(stimulus = as.character(stimulus))
  
  # Get unique categories
  unique_categories <- unique(df_pca$category)
  
  # Initialize an empty data frame to store results
  all_results <- data.frame()
  
  # Get PCA feature columns
  pca_columns <- df_pca %>% select(starts_with(params$pca_prefix)) %>% colnames()
  
  # Loop over each category separately
  for (icategory in unique_categories) {
    
    message("Processing category: ", icategory)
    
    # Subset df_pca for the current category
    df_subset <- df_pca %>% filter(category == icategory)
    
    # Ensure there are at least two images in the category
    if (nrow(df_subset) < 2) {
      next  # Skip this category if not enough data
    }
    
    # Generate all unique image pairs (without redundancy)
    image_pairs <- as.data.frame(t(combn(df_subset$stimulus, 2)))
    colnames(image_pairs) <- c("stimulus_1", "stimulus_2")
    
    # Compute pairwise Pearson correlation for each image pair
    pairwise_results <- image_pairs %>%
      rowwise() %>%
      mutate(
        correlation = cor(
          as.numeric(df_subset[df_subset$stimulus == stimulus_1, pca_columns]),
          as.numeric(df_subset[df_subset$stimulus == stimulus_2, pca_columns])
        )
      ) %>%
      ungroup()
    
    # Apply Fisher Z-transform (optional)
    pairwise_results <- pairwise_results %>%
      mutate(fisher_z = 0.5 * log((1 + correlation) / (1 - correlation)))
    
    # Compute the average Fisher Z for each image
    avg_fisher_z <- pairwise_results %>%
      pivot_longer(cols = c(stimulus_1, stimulus_2), names_to = "image_type", values_to = "stimulus") %>%
      group_by(category = icategory, stimulus) %>%
      summarise(dist_corr = mean(fisher_z, na.rm = TRUE), .groups = "drop")
    
    # Store results
    all_results <- bind_rows(all_results, avg_fisher_z)
  }
  
  # Merge with df_pca to add `dist_corr`
  df_pca <- df_pca %>%
    left_join(all_results, by = c("category", "stimulus"))
  
  message("Done.")
  return(df_pca)
}
