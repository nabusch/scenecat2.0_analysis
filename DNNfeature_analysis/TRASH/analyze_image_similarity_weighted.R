analyze_image_similarity_weighted <- function(df_dist, info, method) {
  
  # ----------------------------------------------------------------------------
  # Initialize vectors to store results
  # ----------------------------------------------------------------------------
  simple_result_values <- numeric(nrow(df_dist))
  weighted_result_values <- numeric(nrow(df_dist))
  
  
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
  for (cat in unique(df_dist$category)) {
    
    # --------------------------------------------------------------------------
    # Get indices for current category
    # --------------------------------------------------------------------------
    cat_indices <- which(df_dist$category == cat)
    n_images <- length(cat_indices)
    
    # --------------------------------------------------------------------------
    # Get feature matrix for current category
    # --------------------------------------------------------------------------
    if (params$dist_pca_dnn == "pca") {
      feature_matrix <- as.matrix(df_dist[cat_indices, info$pca_columns])
      
    } else if (params$dist_pca_dnn == "dnn") {
      feature_matrix <- as.matrix(df_dist[cat_indices, info$dnn_columns])
      
    } else if (params$dist_pca_dnn == "human") {
      
      # Dynamically select the correct category-specific features
      category_feature_col <- paste0(cat, "_features")  # Construct the variable name (e.g., "kitchen_features")
      feature_matrix <- as.matrix(df_dist[cat_indices, info[[category_feature_col]]])
      
    }
    
    # --------------------------------------------------------------------------
    # Scale the feature matrix for correlation and dotproduct methods
    # --------------------------------------------------------------------------
    # if (method %in% c("correlation", "dotproduct")) {
    # feature_matrix <- sign(feature_matrix) * log(abs(feature_matrix) + 1)
    feature_matrix <- scale(feature_matrix, center = TRUE, scale = TRUE)
    # }
    
    # --------------------------------------------------------------------------
    # Initialize matrix to store all pairwise similarities
    # --------------------------------------------------------------------------
    similarity_matrix <- matrix(NA, n_images, n_images)
    
    # Compute all pairwise similarities first
    for (i in 1:n_images) {
      for (j in 1:n_images) {
        if (i != j) {
          sim <- switch(method,
                        correlation = compute_correlation(feature_matrix[i,], feature_matrix[j,]),
                        cosine      = compute_cosine(feature_matrix[i,],      feature_matrix[j,]),
                        dotproduct  = compute_dotproduct(feature_matrix[i,],  feature_matrix[j,]))
          similarity_matrix[i,j] <- sim
        }
      }
    }
    
    # --------------------------------------------------------------------------
    # For each image, compute both simple and weighted measures
    # --------------------------------------------------------------------------
    for (i in 1:n_images) {
      # Get similarities with current image (excluding self)
      sims_with_i <- similarity_matrix[i,][!is.na(similarity_matrix[i,])]
      
      # Get all other pairwise similarities (excluding those involving i)
      other_sims <- similarity_matrix[-i, -i][!is.na(similarity_matrix[-i, -i])]
      
      if (method == "correlation") {
        sim_i <- mean(fisher_z(sims_with_i))
        sim_non_i <- mean(fisher_z(other_sims))
        simple_result_values[cat_indices[i]] <- sim_i
        
      } else {
        sim_i <- mean(sims_with_i)
        sim_non_i <- mean(other_sims)
        simple_result_values[cat_indices[i]] <- sim_i
      }
      
      weighted_result_values[cat_indices[i]] <- sim_i / sim_non_i
    }
  }
  
  # ----------------------------------------------------------------------------
  # Add both result columns to df_dist with appropriate names
  # ----------------------------------------------------------------------------
  base_name <- switch(method,
                      correlation = "dist_corr",
                      cosine      = "dist_cosim",
                      dotproduct  = "dist_dot")
  
  # Add both simple and weighted measures
  df_dist[[base_name]] <- simple_result_values
  df_dist[[paste0(base_name, "_weighted")]] <- weighted_result_values
  
  return(df_dist)
}