fn_distinct_dotprod <- function(df_pca, params){
  
  
  message("Computing pairwise dot products")
  
  # Select PCA columns
  pca_columns <- df_pca %>% select(starts_with(params$pca_prefix)) %>% colnames()
  
  
  # Compute pairwise dot products within each category
  pairwise_dot_products <- df_pca %>%
    group_by(category) %>%
    summarise(
      dot_products = list(
        expand.grid(i = 1:n(), j = 1:n()) %>%
          filter(i < j) %>%  # Avoid redundant calculations
          mutate(
            dot_product = map2_dbl(i, j, ~ sum(
              as.numeric(df_pca[.x, pca_columns]) * as.numeric(df_pca[.y, pca_columns])
            ))
          )
      ),
      .groups = "drop"
    ) %>%
    unnest(dot_products)
  
  
  # Compute the average dot product for each image
  avg_dot_product <- pairwise_dot_products %>%
    pivot_longer(cols = c(i, j), names_to = "image_type", values_to = "image_id") %>%
    group_by(image_id) %>%
    summarise(dist_corr = mean(dot_product, na.rm = TRUE))
  
  # Add the new dist_corr column to df_pca
  df_pca <- df_pca %>%
    mutate(dist_dotp = avg_dot_product$dist_corr[match(1:nrow(df_pca), avg_dot_product$image_id)])
  
  
  message("Done.")
  return(df_pca)
  
}