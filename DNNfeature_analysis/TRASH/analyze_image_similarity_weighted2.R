fn_feature_similarity <- function(df_sim, info, sim_method) {
  
  message("Computing ", sim_method, ".")
  
  # ============================================================================
  # Initialize vectors to store results
  # ============================================================================
  simple_result_values   <- numeric(nrow(df_sim))
  weighted_result_values <- numeric(nrow(df_sim))
  
  
  # ============================================================================
  # Define similarity computation functions
  # ============================================================================
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
  
  fisher_z <- function(r) {
    0.5 * log((1 + r) / (1 - r))
  }
  
  
  # ============================================================================
  # Compute distinctiveness metric for each category separately
  # ============================================================================
  for (cat in unique(df_sim$category)) {
    
    # ----------------------------------------------------------------------------
    # Get the relevant features for the images of the current category.
    # ----------------------------------------------------------------------------
    cat_indices <- which(df_sim$category == cat)
    n_images <- length(cat_indices)
    
    if (params$sim_feature == "pca") {
      feature_matrix <- as.matrix(df_sim[cat_indices, info$pca_columns])
      
    } else if (params$sim_feature == "dnn") {
      feature_matrix <- as.matrix(df_sim[cat_indices, info$dnn_columns])
      
    } else if (params$sim_feature == "human") {
      category_feature_col <- paste0(cat, "_features")
      feature_matrix <- as.matrix(df_sim[cat_indices, info[[category_feature_col]]])
    }
    
    # ----------------------------------------------------------------------------
    # Transform the features.
    # ----------------------------------------------------------------------------
    # feature_matrix <- sign(feature_matrix) * log(abs(feature_matrix) + 1)
    
    feature_matrix <- scale(feature_matrix, center = TRUE, scale = TRUE)
    
    # ----------------------------------------------------------------------------
    # Compute similarity metrics for each pair of images.
    # ----------------------------------------------------------------------------
    if (sim_method == "euclidean" || sim_method == "manhattan") {
      similarity_matrix <- as.matrix(dist(feature_matrix, method = sim_method, diag = FALSE, upper = TRUE))
      
    } else {
      similarity_matrix <- matrix(NA, n_images, n_images)
      for (i in 1:n_images) {
        for (j in 1:n_images) {
          if (i != j) {
            sim <- switch(sim_method,
                          correlation = compute_correlation(feature_matrix[i,], feature_matrix[j,]),
                          cosine      = compute_cosine(feature_matrix[i,],      feature_matrix[j,]),
                          dotproduct  = compute_dotproduct(feature_matrix[i,],  feature_matrix[j,]))
            similarity_matrix[i,j] <- sim
          }
        }
      }
    }
    
    # ----------------------------------------------------------------------------
    # Compute the weighted similarity for each image as the change in similarity
    # without this image.
    # ----------------------------------------------------------------------------
    for (i in 1:n_images) {
      sims_with_i <- similarity_matrix[i,][!is.na(similarity_matrix[i,])]
      other_sims <- similarity_matrix[-i, -i][!is.na(similarity_matrix[-i, -i])]
      
      if (sim_method == "correlation") {
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
  
  
  # ============================================================================
  # Include the results in the main data frame, and name the columns appropriately.
  # ============================================================================
  base_name <- switch(sim_method,
                      correlation = "sim_corr",
                      cosine      = "sim_cosim",
                      dotproduct  = "sim_dot",
                      euclidean   = "sim_eukl",
                      manhattan   = "sim_manhattan")
  
  df_sim[[base_name]] <- simple_result_values
  df_sim[[paste0(base_name, "_weighted")]] <- weighted_result_values
  
  
  return(df_sim)
}
