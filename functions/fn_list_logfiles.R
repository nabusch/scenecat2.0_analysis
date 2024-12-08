fn_list_logfiles <- function(dirs, base_string) {
  
  # List all .csv files.
  logfile_list <- list.files(path = dirs$logfiles, pattern = "\\.csv$", full.names = TRUE)
  
  # Filter files that contain the base_string.
  logfile_list <- logfile_list[grepl(base_string, logfile_list)]
  
  # Print the summary message to the console.
  cat(sprintf("I found %d logfiles in %s\n", length(logfile_list), dirs$data))
  if (length(logfile_list) > 0) {
    cat("The logfiles are:\n")
    print(logfile_list)
  } else {
    cat("No matching logfiles were found.\n")
  }

  return(logfile_list)
}
