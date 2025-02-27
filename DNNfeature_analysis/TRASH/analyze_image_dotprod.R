analyze_image_dotprod <- function(df_dist, info) {
  
  # Initialize vector to store results
  avg_dot_values <- numeric(nrow(df_dist))
  
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
      
      # Compute dot products with all other images
      dot_products <- sapply(seq_along(cat_indices), function(j) {
        if (i == j) return(NA)  # Skip self-product
        sum(current_features * feature_matrix[j, ])
      })
      
      # Remove NA (self-product) and compute mean
      avg_dot_values[cat_indices[i]] <- mean(dot_products[!is.na(dot_products)])
    }
  }
  
  # ----------------------------------------------------------------------------
  # Add the results column to df_dist
  # ----------------------------------------------------------------------------
  df_dist$dist_dot <- avg_dot_values
  
  return(df_dist)
}