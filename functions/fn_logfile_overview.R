fn_logfile_overview <- function(logfile_list, vars) {
  # Initialize an empty data frame to store results
  summary_data <- data.frame()
  
  # Loop over all files in the list
  index <- 1
  for (file_path in logfile_list) {
    
    # Read the file
    data <- read.csv(file_path)
    
    source(file.path(dirs$functions, "fn_german_to_english.R"))
    data <- fn_german_to_english(data, vars$column_renames)
    
    # Extract metadata
    ID          <- unique(data$participant)
    Age         <- unique(data$Age)
    Gender      <- unique(data$Gender)
    Handedness  <- unique(data$Handedness)
    Date        <- unique(data$date)
    SubjectCode <- data$vpcode[which.max(seq_along(data$vpcode))] # Get the value of vpcode from the last line
    
    # Ensure date is properly parsed
    date_parsed <- lubridate::ymd_hms(Date)
    day  <- format(date_parsed, "%Y-%m-%d")
    time <- format(date_parsed, "%H:%M:%S")
    
    # Count rows for memory and categorization tasks
    nMemTrials <- sum(data$task == "memory", na.rm = TRUE)
    nCatTrials <- sum(data$task == "categorization", na.rm = TRUE)
    nTotTrials <- nMemTrials + nCatTrials
    
    # Create a row summarizing the data
    summary_row <- data.frame(
      Index        = index,
      ID           = ID,
      SubjectCode  = SubjectCode,
      Age          = Age,
      Gender       = Gender,
      Handedness   = Handedness,
      Day          = day,
      Time         = time,
      nMemTrials   = nMemTrials,
      nCatTrials   = nCatTrials,
      nTotTrials   = nTotTrials,
      Filename     = basename(file_path), # Add the filename of the CSV
      stringsAsFactors = FALSE
    )
    
    # Append the row to the summary data
    summary_data <- rbind(summary_data, summary_row)
    index <- index + 1
  }
  
  # Write output file.
  require(openxlsx)  # Make sure to load the openxlsx package
  
  overview_name <- paste0(vars$exp_name, "_overview.xlsx")
  cat(sprintf("Saving logfile overview to %s\n", overview_name))
  write.xlsx(summary_data, file = file.path(dirs$main, overview_name), rowNames = FALSE)
  
  
  return(summary_data)
}
