fn_extract_extremes <- function(df_dist, params) {
  
  # Prepare a subset of df_dist with only relevant columns
  df_prepared <- df_dist %>%
    select(stimulus, category, !!sym(params$dist_metric)) %>%
    rename(distm = !!sym(params$dist_metric))
  
  message("Extracting extreme values...")
  
  N <- params$n_extremes
  
  # Compute extremes per category
  extreme_values <- df_prepared %>%
    group_by(category) %>%
    summarise(
      min_images = list(stimulus[order(distm)][1:N]),
      max_images = list(stimulus[order(desc(distm))][1:N]),
      min_vals = list(distm[order(distm)][1:N]),
      max_vals = list(distm[order(desc(distm))][1:N]),
      .groups = "drop"
    )
  
  message("Extraction complete.")
  return(extreme_values)
}
