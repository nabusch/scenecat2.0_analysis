fn_german_to_english <- function(data, column_renames) {
  
  # Rename columns if they exist
  for (col in names(column_renames)) {
    if (col %in% colnames(data)) {
      colnames(data)[colnames(data) == col] <- column_renames[col]
    }
  }
  
  # Translate values in the Gender column
  if ("Gender" %in% colnames(data)) {
    data$gender <- gsub("männlich|maennlich", "m", data$gender, ignore.case = TRUE)
    data$gender <- gsub("w|weiblich", "f", data$gender, ignore.case = TRUE)
  }
  
  # Translate values in the Handedness column
  if ("Handedness" %in% colnames(data)) {
    data$handedness <- gsub("links", "l", data$handedness, ignore.case = TRUE)
    data$handedness <- gsub("rechts", "r", data$handedness, ignore.case = TRUE)
  }
  
  return(data)
}