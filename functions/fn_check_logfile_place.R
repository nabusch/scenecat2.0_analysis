fn_check_logfile_place <- function(data, vars) {
  
  # message("Checking where the data were collected.")
  
  # Initialize place as NULL
  place <- NULL
  
  # # Iterate through the list and check for matching columns
  # for (column_name in names(vars$place_strings)) {
  #   if (column_name %in% colnames(data)) {
  #     place <- vars$place_strings[[column_name]]
  #     break # Stop after the first match
  #   }
  # }
  
  
  # Iterate through the list and check if column_name is a substring of any column names
  for (column_name in names(vars$place_strings)) {
    match <- grepl(column_name, colnames(data))
    if (any(match)) {
      place <- vars$place_strings[[column_name]]
      break # Stop after the first match
    }
  }
  
  
  # Add a warning if no match is found
  if (is.null(place)) {
    warning("No column indicating the place found in the data frame.")
  }
    
  # Return the value of place
  return(place)
}