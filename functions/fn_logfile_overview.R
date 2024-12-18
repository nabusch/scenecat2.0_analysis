fn_logfile_overview <- function(logfile_list, vars, dirs) {
  
  summary_data <- data.frame()
  
  # Loop over all files in the list
  index <- 1
  for (file_path in logfile_list) {
    
    # Read the file
    data <- read.csv(file_path)
    
    # Check where the data where collected.
    source(file.path(dirs$functions, "fn_check_logfile_place.R"))
    place <- fn_check_logfile_place(data, vars)
    
    source(file.path(dirs$functions, "fn_german_to_english.R"))
    data <- fn_german_to_english(data, vars$column_renames)
    
    # Makes sure that demographic variables are not empty. 
    variables <- c("age", "gender", "handedness", "email.for.compensation")
    
    # Create a named list of the variables with values or NA
    result <- lapply(variables, function(var) {
      if (!is.null(data[[var]]) && length(unique(data[[var]])) == 1) {
        unique(data[[var]])
      } else {
        NA
      }
    })
    
    # Extract metadata
    ID          <- unique(data$participant)
    Age         <- unique(data$age)
    Gender      <- unique(data$gender)
    Handedness  <- unique(data$handedness)
    Date        <- unique(data$date)
    
    
    # Process the subject codes, depending on the place where the data where
    # collected. This is important because we used slightly different versions
    # because our institutes had different ways to compensate participants.
    if (place == "Muenster") {
      # Get the value of vpcode from the last row, ensuring it's a single unique value
      SubjectCode <- data$vpcode[which.max(seq_along(data$vpcode))]
      if (is.na(SubjectCode) || SubjectCode == "" || length(SubjectCode) != 1) {
        SubjectCode <- NA # Assign NA if vpcode is empty or not a single unique value
      }
    } else if (place == "Prague") {
      require(stringr)
      
      # Define a regex for email addresses
      email_regex <- "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+[,\\.][a-zA-Z]{2,}" # some people entered ",com"
      
      
      # Extract email addresses from the data frame
      SubjectCode <- unique(na.omit(str_extract(as.matrix(data), email_regex)))
      if (length(SubjectCode) == 0) {
        SubjectCode <- NA
      }
    }
    
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
      Place        = place,
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
  
  overview_name <- paste0(vars$exp_name, "_", place, "_overview.xlsx")
  cat(sprintf("Saving logfile overview to %s\n", overview_name))
  write.xlsx(summary_data, file = file.path(dirs$data, overview_name), rowNames = FALSE)
  
  return(summary_data)
}

