analyze_image_similarity <- function(df_dist, info, method = c("correlation", "cosine", "dotproduct")) {
  
  # Validate and match the method argument
  method <- match.arg(method)
  message("Computing distinctiveness by ", method, ".")
  
  # Initialize vector to store results
  result_values <- numeric(nrow(df_dist))
  
  # ----------------------------------------------------------------------------
  # Define similarity computation functions
  # ----------------------------------------------------------------------------
  compute_correlation <- function(vec1, vec2) {
    cor(vec1, vec2)
  }
  
  compute_cosine <- function(vec1, vec2) {
    dot_prod <- sum(vec1 * vec2)
    norm1 <- sqrt(sum(vec1^2))
    norm2 <- sqrt(sum(vec2^2))
    dot_prod / (norm1 * norm2)
  }
  
  compute_dotproduct <- function(vec1, vec2) {
    sum(vec1 * vec2)
  }
  
  # Fisher's z-transformation for correlation method
  fisher_z <- function(r) {
    0.5 * log((1 + r) / (1 - r))
  }
  
  # ----------------------------------------------------------------------------
  # Compute distinctiveness metric for each category separately
  # ----------------------------------------------------------------------------
  for (cat in info$categories) {
    
    # Get indices for current category
    cat_indices <- which(df_dist$category == cat)
    
    # Get feature matrix for current category
    feature_matrix <- as.matrix(df_dist[cat_indices, info$pca_columns])
    
    # Scale the feature matrix for correlation and dotproduct methods
    if (method %in% c("correlation", "dotproduct")) {
      feature_matrix <- scale(feature_matrix, center = TRUE, scale = TRUE)
    }
    
    # Experimental: log transform the PCA values.
    # feature_matrix <- sign(feature_matrix) * log(abs(feature_matrix) + 1)
    
    # For each image in the category
    for (i in seq_along(cat_indices)) {
      # Get current image features
      current_features <- feature_matrix[i, ]
      
      # Compute similarities with all other images
      similarities <- sapply(seq_along(cat_indices), function(j) {
        if (i == j) return(NA)  # Skip self-comparison
        
        # Select appropriate similarity measure based on method
        switch(method,
               correlation = compute_correlation(current_features, feature_matrix[j, ]),
               cosine      = compute_cosine(current_features,      feature_matrix[j, ]),
               dotproduct  = compute_dotproduct(current_features,  feature_matrix[j, ]))
      })
      
      # Process similarities based on method
      if (method == "correlation") {
        z_scores <- fisher_z(similarities[!is.na(similarities)])
        result_values[cat_indices[i]] <- mean(z_scores)
      } else {
        result_values[cat_indices[i]] <- mean(similarities[!is.na(similarities)])
      }
    }
  }
  
  # ----------------------------------------------------------------------------
  # Add the results column to df_dist with appropriate name
  # ----------------------------------------------------------------------------
  column_name <- switch(method,
                        correlation = "dist_corr",
                        cosine      = "dist_cosim",
                        dotproduct  = "dist_dot")
  
  df_dist[[column_name]] <- result_values
  
  return(df_dist)
}