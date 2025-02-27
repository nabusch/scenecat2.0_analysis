fn_run_pca <- function(df_features, params, info){
  
  message("Computing PCA.")
  
  # ----------------------------------------------------------------------------
  # Perform PCA
  # ----------------------------------------------------------------------------
  pca_result <- prcomp(df_features[, info$dnn_columns], center = TRUE, scale. = TRUE)

    
  # ----------------------------------------------------------------------------
  # Compute explained variance
  # ----------------------------------------------------------------------------
  explained_variance <- pca_result$sdev^2 / sum(pca_result$sdev^2)
  cumulative_variance <- cumsum(explained_variance)

    
  # ----------------------------------------------------------------------------
  # Find the number of PCs needed to explain X% of the variance
  # ----------------------------------------------------------------------------
  ncomps <- which(cumulative_variance >= params$pca_exvar)[1]
  message("Extracting ", ncomps, " PCA components explaining ", params$pca_exvar ," of the variance.")
  
  
  # ----------------------------------------------------------------------------
  # Extract only those components.
  # ----------------------------------------------------------------------------
  pca_reduced <- as.data.frame(pca_result$x[, 1:ncomps])
  
  
  # ----------------------------------------------------------------------------
  # Rename the components (PC1, PC2, ..., PCncomps)
  # ----------------------------------------------------------------------------
  colnames(pca_reduced) <- paste0(params$pca_prefix, 1:ncomps)
  info$pca_columns <- colnames(pca_reduced)
  
  
  # ----------------------------------------------------------------------------
  # Add PCA components to the original dataframe
  # ----------------------------------------------------------------------------
  df_pca <- cbind(df_features, pca_reduced)
  
  
  message("Done.")
  return(list(df_pca = df_pca, info = info))  
}