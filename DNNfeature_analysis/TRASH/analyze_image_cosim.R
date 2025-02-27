analyze_image_cosim <- function(df_dist, info) {
  
  # Initialize vector to store results
  avg_cos_values <- numeric(nrow(df_dist))
  
  # ----------------------------------------------------------------------------
  # Compute distinctiveness metric for each category separately
  # ----------------------------------------------------------------------------
  for (cat in unique(df_dist$category)) {
    
    # Get indices for current category
    cat_indices <- which(df_dist$category == cat)
    
    # Get feature matrix for current category
    feature_matrix <- as.matrix(df_dist[cat_indices, info$pca_columns])
    
    # For each image in the category
    for (i in seq_along(cat_indices)) {
      # Get current image features
      current_features <- feature_matrix[i, ]
      
      # Compute cosine similarities with all other images
      cosine_sims <- sapply(seq_along(cat_indices), function(j) {
        if (i == j) return(NA)  # Skip self-comparison
        
        # Compute cosine similarity: dot product of normalized vectors
        dot_prod <- sum(current_features * feature_matrix[j, ])
        norm_i <- sqrt(sum(current_features^2))
        norm_j <- sqrt(sum(feature_matrix[j, ]^2))
        dot_prod / (norm_i * norm_j)
      })
      
      # Remove NA (self-comparison) and compute mean
      avg_cos_values[cat_indices[i]] <- mean(cosine_sims[!is.na(cosine_sims)])
    }
  }
  
  # ----------------------------------------------------------------------------
  # Add the results column to df_dist
  # ----------------------------------------------------------------------------
  df_dist$dist_cosim <- avg_cos_values

  return(df_dist)
}