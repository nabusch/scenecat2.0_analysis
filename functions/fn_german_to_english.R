fn_german_to_english <- function(data, column_renames) {
  # Rename columns if they exist
  for (col in names(column_renames)) {
    if (col %in% colnames(data)) {
      colnames(data)[colnames(data) == col] <- column_renames[col]
    }
  }
  
  # Translate values in the Gender column
  if ("Gender" %in% colnames(data)) {
    data$Gender <- gsub("männlich|maennlich", "m", data$Gender, ignore.case = TRUE)
    data$Gender <- gsub("w|weiblich", "f", data$Gender, ignore.case = TRUE)
  }
  
  # Translate values in the Handedness column
  if ("Handedness" %in% colnames(data)) {
    data$Handedness <- gsub("links", "l", data$Handedness, ignore.case = TRUE)
    data$Handedness <- gsub("rechts", "r", data$Handedness, ignore.case = TRUE)
  }
  
  return(data)
}