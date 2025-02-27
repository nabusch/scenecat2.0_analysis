analyze_image_correlations <- function(df_dist, info) {
  
  # Initialize vector to store results
  avg_fisher_z_values <- numeric(nrow(df_dist))

  # ----------------------------------------------------------------------------
  # Function to convert Fisher's r to z
  # ----------------------------------------------------------------------------
  fisher_z <- function(r) {0.5 * log((1 + r) / (1 - r))}
  
  # ----------------------------------------------------------------------------
  # Compute distinctiveness metric for each category separately
  # ----------------------------------------------------------------------------
  for (cat in unique(df_dist$category)) {
    
    # Get indices for current category
    cat_indices <- which(df_dist$category == cat)
    
    # Get feature matrix for current category
    feature_matrix <- as.matrix(df_dist[cat_indices, info$pca_columns])
    
    feature_matrix <- scale(feature_matrix, center = TRUE, scale = TRUE)

    
    # For each image in the category
    for (i in seq_along(cat_indices)) {
      # Get current image features
      current_features <- feature_matrix[i, ]
      
      # Compute correlations with all other images
      correlations <- sapply(seq_along(cat_indices), function(j) {
        if (i == j) return(NA)  # Skip self-correlation
        cor(current_features, feature_matrix[j, ])
      })
      
      # Remove NA (self-correlation) and transform to Fisher's z
      z_scores <- fisher_z(correlations[!is.na(correlations)])
      
      # Compute average z-score and store in the vector
      avg_fisher_z_values[cat_indices[i]] <- mean(z_scores)
    }
  }
  
  # ----------------------------------------------------------------------------
  # Add the results column to df_dist
  # ----------------------------------------------------------------------------
  df_dist$dist_corr <- avg_fisher_z_values
  
  return(df_dist)
}