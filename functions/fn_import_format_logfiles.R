fn_import_format_logfiles <- function(vars, raw_data){
  
  # Unify the columns coding responses in the categorization task.
  all_data <- raw_data %>% 
    rename(mem_response = memotest_task_slider_key_resp.keys) %>%
    rename(gender = Gender) %>%
    rename(handed = Handedness) %>%
    rename(age    = Age) %>%
    unite(cat_key,  kitchen_picture_resp.keys, bed_picture_resp.keys, living_picture_resp.keys, sep = "", na.rm = TRUE) %>% 
    unite(cat_corr, kitchen_picture_resp.corr, bed_picture_resp.corr, living_picture_resp.corr, sep = "", na.rm = TRUE) %>%
    unite(cat_rt,   kitchen_picture_resp.rt,   bed_picture_resp.rt,   living_picture_resp.rt,   sep = "", na.rm = TRUE) %>% 
    select(-ends_with(".keys"), -ends_with(".corr"), -ends_with(".rt"))
  
  # Rename German column names.
  #all_data <- all_data %>% rename(!!!setNames(names(vars$columns_to_rename), vars$columns_to_rename))
  
  # Remove rows that are neither categorization nor memory, i.e. the training trials.
  all_data <- all_data  %>%  filter(task %in% c("categorization", "memory"))
  
  all_data$cat_rt <- as.numeric(all_data$cat_rt)
  all_data$cat_corr <- as.numeric(all_data$cat_corr)

  all_data <- all_data %>%
    mutate(mem_response = as.character(mem_response),
           mem_response = str_replace_all(mem_response, "d", "sure old"),
           mem_response = str_replace_all(mem_response, "f", "maybe old"),
           mem_response = str_replace_all(mem_response, "j", "sure new"),
           mem_response = str_replace_all(mem_response, "k", "sure old"))  

  all_data <- all_data %>%
    mutate(mem_perform = case_when(
      cond_mem == "old" & str_detect(mem_response, "old") ~ "hit",
      cond_mem == "old" & str_detect(mem_response, "new") ~ "miss",
      cond_mem == "new" & str_detect(mem_response, "old") ~ "fa",
      cond_mem == "new" & str_detect(mem_response, "new") ~ "corej",
      TRUE ~ NA_character_ # Default case if none of the above conditions are met
    ))  
  
  # Select only the columns we are interested in.
  all_data <- all_data %>% select(all_of(vars$columns_of_interest))
  
  # Write output file.
  require(openxlsx)  # Make sure to load the openxlsx package
  
  cleandata_name <- paste0(vars$exp_name, "_", place, "_formatted_logs.xlsx")
  cat(sprintf("Saving formatted logfile data to %s\n", cleandata_name))
  write.xlsx(all_data, file = file.path(dirs$main, cleandata_name), rowNames = FALSE)
  
  
  
  return(all_data)
}