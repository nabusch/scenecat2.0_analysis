fn_prep_data <- function(df_features, params, info){
  
  message("Preparing data.")
  
  # ----------------------------------------------------------------------------
  # Get names of DNN feature columns (V1 to V4096)
  # ----------------------------------------------------------------------------
  info$dnn_columns <- grep(paste0("^", params$dnn_features_prefix), names(df_features), value = TRUE)
  info$categories <- unique(df_features$category)
  
  
  # ----------------------------------------------------------------------------
  # Find human feature columns for a specific category.
  # ----------------------------------------------------------------------------
  get_category_features <- function(df, target_category) {
    df_category <- df %>% filter(category == target_category)  # Subset for the target category
    
    # Find columns with values only in this category and NAs in all others
    feature_cols <- names(df)[colSums(!is.na(df_category)) > 0 & colSums(!is.na(df[df$category != target_category, ])) == 0]
    
    return(feature_cols)
  }
  
  # Every category has a different set of human-defined features (e.g. bed-ness
  # is only a feature for the bedroom category. Get lists of feature columns for
  # each category
  info$bedroom_features     <- get_category_features(df_features, "bedroom")
  info$kitchen_features     <- get_category_features(df_features, "kitchen")
  info$living_room_features <- get_category_features(df_features, "living_room")
  
  
  # ----------------------------------------------------------------------------
  # Remove rows (images) that have any NAs, this happens for the images that
  # were not used in the experiments and so do not have any behavioral data.
  # ----------------------------------------------------------------------------
  df_features <- df_features %>% drop_na(img_cat_rt, mem_dprime, mem_crit)
  
  
  # ----------------------------------------------------------------------------
  # Remove rows of bad images(e.g. duplicates or images that were later
  # identified as including text labels).
  # ----------------------------------------------------------------------------
  require(stringr)
  require(dplyr)
  message("Removing these bad images from the dataset:")
  print(sprintf("%s", params$bad_imgs))
  
  df_features <- df_features %>%
    filter(!str_detect(stimulus, paste0(params$bad_imgs, collapse = "|")))
  
  
  # ----------------------------------------------------------------------------
  # Set appropriate variables types.
  # ----------------------------------------------------------------------------
  df_features <- df_features %>% mutate(stimulus = as.character(stimulus))
  df_features <- df_features %>% mutate(category = factor(category))
  df_features <- df_features %>% mutate(across(all_of(info$feature_columns), as.numeric))
  
  
  message("Done.")
  return(list(df_features = df_features, info = info))
  
}
