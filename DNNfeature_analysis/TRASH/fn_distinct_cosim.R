
fn_distinct_cosim <- function(df_pca, info) {
  
  # Initialize vector to store results
  avg_cosine_values <- numeric(nrow(df_pca))
  
  
  compute_cosine_similarity <- function(x, y) {
    x_norm <- norm(x)
    y_norm <- norm(y)
    ifelse(x_norm == 0 || y_norm == 0, NA, sum(x * y) / (x_norm * y_norm))
  }
  
  
  # ----------------------------------------------------------------------------
  # Compute distinctiveness metric for each category separately
  # ----------------------------------------------------------------------------
  for (cat in unique(df_pca$category)) {
    
    # Get indices for current category
    cat_indices <- which(df_pca$category == cat)
    
    # Get feature matrix for current category
    feature_matrix <- as.matrix(df_pca[cat_indices, info$pca_columns])
    
    # For each image in the category
    for (i in seq_along(cat_indices)) {
      # Get current image features
      current_features <- feature_matrix[i, ]
      
      # Compute pairwise inner products with all other images
      pairwise_inner_products <- sapply(seq_along(cat_indices), function(j) {
        if (i == j) return(NA)  # Skip self-product
        sum(current_features * feature_matrix[j, ])
      })
      
      # Compute cosine similarities
      cosine_similarities <- mapply(compute_cosine_similarity, as.matrix(current_features), feature_matrix[-i, ])
      
      # Remove NAs (self-similarity) and compute mean
      avg_cosine_values[cat_indices[i]] <- mean(cosine_similarities[!is.na(cosine_similarities)])
    }
  }
  
  # ----------------------------------------------------------------------------
  # Add the results column to df_pca
  # ----------------------------------------------------------------------------
  df_pca$dist_cosine <- avg_cosine_values
  
  return(df_pca)
}
