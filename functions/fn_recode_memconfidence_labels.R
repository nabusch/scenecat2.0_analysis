fn_recode_memconfidence_labels <- function(all_data){
  
  
  # Transform the confidence labels into numerical data.
  all_data <- all_data %>%
    mutate(mem_response_num = case_when(
      mem_response == "sure old"  ~ 1,
      mem_response == "maybe old" ~ 2/3,
      mem_response == "maybe new" ~ 1/3,
      mem_response == "sure new"  ~ 0,
      TRUE                        ~ NA_real_ # Handles cases that don't match any condition
    ))
  
  # To insert mem_response_num immediately to the right of mem_response
  # Assuming you want to do this without specifying column names manually
 # col_order <- match("mem_response", names(all_data)) # Find position of mem_response
  #all_data <- all_data %>%
  #  select(1:col_order, mem_response_num, (col_order+1):(ncol(all_data)-1))
  
  # Find the position of the "mem_response" column
  mem_response_pos <- which(names(all_data) == "mem_response")
  
  # Insert "mem_response_num" column to the right of "mem_response"
  all_data <- all_data %>%
    relocate(mem_response_num, .after = mem_response)
  
  
  
  return(all_data)
  
}