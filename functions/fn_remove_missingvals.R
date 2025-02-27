fn_remove_missingvals <- function(summary, vars){
  
  # Identify participants with any NA values
  participants_with_na <- summary %>%
    filter_all(any_vars(is.na(.))) %>%
    select(participant) %>%
    distinct()
  
  # Remove rows for participants with any NA values
  summary <- summary %>%
    anti_join(participants_with_na, by = "participant")
  
  # Number of unique participants removed
  num_removed <- n_distinct(participants_with_na$participant)
  
  # List of unique participants removed
  removed_participants <- participants_with_na %>%
    pull(participant)
  
  # Some subjects (#23) have incomplete datasets. We must make sure that all subjects have a complete set of rows in the data table. 
  summary <- summary %>%
    ungroup() %>%  
    complete(participant, typi_bin = c("high", "low"), category = vars$categories) 
  
  # Print the number of participants removed and the list of unique participants
  cat("Number of participants removed with missing values:", num_removed, "\n")
  cat("Participants Removed:", paste(removed_participants, collapse = ", "), "\n")
  
  return(summary)           
}