analzye_image_euclideandist <- function(df_dist, info) {
  
  # ----------------------------------------------------------------------------
  # Initialize vectors to store results
  # ----------------------------------------------------------------------------
  simple_result_values <- numeric(nrow(df_dist))
  weighted_result_values <- numeric(nrow(df_dist))
  
  
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
      
      
      if (!category_feature_col %in% names(info)) {
        stop(paste("Error: No feature list found for category", cat))
      }
      
    }
    
    # --------------------------------------------------------------------------
    # Scale the feature matrix 
    # --------------------------------------------------------------------------
    
    # feature_matrix <- sign(feature_matrix) * log(abs(feature_matrix) + 1)
    feature_matrix <- scale(feature_matrix, center = TRUE, scale = TRUE)
    
    # --------------------------------------------------------------------------
    # Compute euclidean distance.
    # --------------------------------------------------------------------------
    similarity_matrix <- as.matrix(dist(feature_matrix, method = "manhattan", diag = FALSE, upper = TRUE))
    
    # --------------------------------------------------------------------------
    # For each image, compute both simple and weighted measures
    for (i in 1:n_images) {
      # Get similarities with current image (excluding self)
      sims_with_i <- similarity_matrix[i,][!is.na(similarity_matrix[i,])]
      
      # Get all other pairwise similarities (excluding those involving i)
      other_sims <- similarity_matrix[-i, -i][!is.na(similarity_matrix[-i, -i])]
      
      sim_i <- mean(sims_with_i)
      sim_non_i <- mean(other_sims)
      simple_result_values[cat_indices[i]] <- sim_i
      
      weighted_result_values[cat_indices[i]] <- sim_i / sim_non_i
    }
  }
  
  # ----------------------------------------------------------------------------
  # Add both result columns to df_dist with appropriate names
  # ----------------------------------------------------------------------------
  base_name <- "dist_eukl"
  
  # Add both simple and weighted measures
  df_dist[[base_name]] <- simple_result_values
  df_dist[[paste0(base_name, "_weighted")]] <- weighted_result_values
  
  return(df_dist)
}