fn_read_feature_csv <- function(params){
  
  the_file <- file.path(params$dir_csv, params$csv_name)
  
  message("Loading ", the_file, ".")
  
  df_features <- read.csv(the_file)
  
  message("Done.")
  return(df_features)
}