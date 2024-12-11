fn_import_read_logfiles <- function(logfile_list, vars){
  
  
  # Initialize an empty data frame
  raw_data <- data.frame()
  
  # Loop through the files and read only the columns of interest.
  for (file in logfile_list) {
    
    print(sprintf('Reading file: %s.', file))
    
    # Read the file
    data <- read_csv(file, col_names = TRUE, show_col_types = FALSE)
    
    # Check where the data where collected.
    source(file.path(dirs$functions, "fn_check_logfile_place.R"))
    data$place <- fn_check_logfile_place(data, vars)
    
    
    # If there are German column names, translate to English.
    source(file.path(dirs$functions, "fn_german_to_english.R"))
    data <- fn_german_to_english(data, vars$column_renames)
    
    # Extract the subject's numeric index from the file name, add the 'id' column and make it the first column.
    #prefix_number <- as.numeric(str_extract(basename(file), "^\\d+"))
    #data <- data %>% mutate(id = prefix_number) %>% select(id, everything())
    
    # For some reason, some columns are coded as logical in sme subjects, and as
    # character in other subjects. We need to make it consistent for the
    # bind_rows to work.
    data$gender <- as.character(data$gender)
    data$memo_training_slider_key_resp.keys <- as.character(data$memo_training_slider_key_resp.keys)
    
    
    
    # Append this dataset to the other datasets.
    raw_data <- bind_rows(raw_data, data)
  }
  
  return(raw_data)
}