fn_check_logfile_place <- function(data, vars) {
  
  # Initialize place as NULL
  place <- NULL
  
  # Iterate through the list and check for matching columns
  for (column_name in names(vars$place_strings)) {
    if (column_name %in% colnames(data)) {
      place <- vars$place_strings[[column_name]]
      break # Stop after the first match
    }
  }
  
  # Return the value of place
  return(place)
}