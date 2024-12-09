fn_list_logfiles <- function(dirs, vars, base_string) {
  
  # List all .csv files.
  logfile_list <- list.files(path = dirs$logfiles, pattern = "\\.csv$", full.names = TRUE)
  
  # Filter files that contain the base_string.
  logfile_list <- logfile_list[grepl(base_string, logfile_list)]
  
  
  # Get file information
  file_info <- file.info(logfile_list)
  
  # Filter files with size > 100 KB (100 * 1024 bytes)
  logfile_list <- logfile_list[file_info$size > vars$min_logfile_kbsize * 1024]
  
  
  
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
