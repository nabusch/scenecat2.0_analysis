fn_load_cleandata <- function(vars, dirs){
  
  
  if (vars$flavor == "online") {
    online_data <- read.csv(file = file.path(dirs$data, paste0("scenecat_", vars$version, "_online_cleandata.csv")), stringsAsFactors = FALSE) %>% 
      mutate(participant = participant + 100) %>%
      mutate(category = as.factor(category)) %>%
      mutate(flavor = "online")
    
    all_data <- online_data
    
  } else if (vars$flavor == "local") {
    local_data <- read.csv(file = file.path(dirs$data, paste0("scenecat_", vars$version, "_local_cleandata.csv")), stringsAsFactors = FALSE)  %>%
      mutate(category = as.factor(category)) %>%
      mutate(flavor = "local")
    
    all_data <- local_data
    
  } else if (vars$flavor == "both") {
    
    local_data <- read.csv(file = file.path(dirs$data, paste0("scenecat_", vars$version, "_local_cleandata.csv")), stringsAsFactors = FALSE)  %>%
      mutate(category = as.factor(category)) %>%
      mutate(flavor = "local")
    
    online_data <- read.csv(file = file.path(dirs$data, paste0("scenecat_", vars$version, "_online_cleandata.csv")), stringsAsFactors = FALSE) %>% 
      mutate(participant = participant + 100) %>%
      mutate(category = as.factor(category)) %>%
      mutate(flavor = "online")
    
    all_data <- rbind(local_data, online_data)
    
  } else {
    message("Unknown flavor. Please check the value of vars$flavor.")
  }
  
  return(all_data)
  
  
  
}