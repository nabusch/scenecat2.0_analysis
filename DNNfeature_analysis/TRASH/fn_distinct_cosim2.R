fn_distinct_cosim2 <- function(df_pca, params){
  
  message("Computing pairwise cosine similarities.")
  
  # Ensure stimulus is a character to avoid factor issues
  df_pca <- df_pca %>% mutate(stimulus = as.character(stimulus))
  
  # Get unique categories
  unique_categories <- unique(df_pca$category)
  
  # Initialize an empty data frame to store results
  all_results <- data.frame()
  
  # Select PCA columns
  pca_columns <- df_pca %>% select(starts_with(params$pca_prefix)) %>% colnames()
  
  # Function to compute cosine similarity
  cosine_similarity <- function(vec1, vec2) {
    sum(vec1 * vec2) / (sqrt(sum(vec1^2)) * sqrt(sum(vec2^2)))
  }
  
  # Loop over each category separately
  for (icategory in unique_categories) {
    
    message("Processing category: ", icategory)
    
    # Subset df_pca for the current category
    df_subset <- df_pca %>% filter(category == icategory)
    
    # Generate all unique image pairs (without redundancy)
    image_pairs <- as.data.frame(t(combn(df_subset$stimulus, 2)))
    colnames(image_pairs) <- c("stimulus_1", "stimulus_2")
    
    
    # Compute pairwise cosine similarities within each category
    pairwise_cosine <- df_subset %>%
      group_by(category) %>%
      summarise(
        similarities = list(
          expand.grid(i = 1:n(), j = 1:n()) %>%
            filter(i < j) %>%  # Avoid redundant calculations
            mutate(
              cosine_sim = map2_dbl(i, j, ~ cosine_similarity(
                as.numeric(df_subset[.x, pca_columns]),
                as.numeric(df_subset[.y, pca_columns])
              ))
            )
        ),
        .groups = "drop"
      ) %>%
      unnest(similarities)
    
    
    # Compute the average cosine similarity for each image
    avg_cosine_sim <- pairwise_cosine %>%
      pivot_longer(cols = c(i, j), names_to = "image_type", values_to = "image_id") %>%
      group_by(image_id) %>%
      summarise(dist_cosim = mean(cosine_sim, na.rm = TRUE))
    
    # Store results
    all_results <- bind_rows(all_results, avg_cosine_sim)
  }
  
  # Add the new dist_corr column to df_pca
  df_pca <- df_pca %>%
    mutate(dist_cosim = all_results$dist_cosim[match(1:nrow(df_pca), all_results$image_id)])
  
  
  
  message("Done.")
  return(df_pca)
  
  
  
  
}