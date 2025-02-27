fn_get_demographics <- function(data, id){
  
  demographics <- list()
  
    # Group by participants and summarize the necessary statistics
  demographic_data <- data %>%
    group_by_at(id) %>%
    summarise(
      age = first(as.numeric(age)),    
      gender = first(gender),          
      handed = first(handed)           
    )
  
  # Number of unique participants
  demographics$n           <- nrow(demographic_data)
  demographics$mean_age    <- mean(demographic_data$age, na.rm = TRUE)
  demographics$min_age     <- min(demographic_data$age, na.rm = TRUE)
  demographics$max_age     <- max(demographic_data$age, na.rm = TRUE)
  demographics$n_female    <- sum(demographic_data$gender == 'f', na.rm = TRUE)
  demographics$n_male      <- sum(demographic_data$gender == 'm', na.rm = TRUE)
  demographics$n_divgender <- sum(!demographic_data$gender %in% c('f', 'm'), na.rm = TRUE)
  demographics$n_righthand <- sum(demographic_data$handed == 'right', na.rm = TRUE)
  
  return(demographics)
  
}