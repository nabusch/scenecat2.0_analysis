fn_flagbad_mem_accuracy <- function(summary_mem_accuracy, all_data, vars){
  
  # Identify bad participants:
  # - If their mem. d' is lower than critical value.
  # - If their number of trials is lower than critical value.
  
  bad_dp <- summary_mem_accuracy %>%
    group_by(participant) %>%
    summarize(
      is_bad = any(mem_dprime < vars$mem_dprime_min | ntrials_mem < vars$mem_ntrials_min),
      .groups = 'drop' # Drop the automatic grouping to avoid issues later
    ) %>%
    filter(is_bad) 
  
  bad_catch <- summary_mem_accuracy %>%
    group_by(participant) %>%
    summarize(
      n_catch = first(n_catch), 
      is_bad = n_catch > vars$mem_ncatch_max,
      .groups = 'drop' # Drop the automatic grouping to avoid issues later
    ) %>%
    filter(is_bad) 
  
  
  # Update the summary data.
  summary_mem_accuracy <- summary_mem_accuracy %>%
    mutate(bad_mem_dp = if_else(participant %in% bad_dp$participant, 1, 0)) %>%
    mutate(bad_catch  = if_else(participant %in% bad_catch$participant, 1, 0))
  
  
  # Flag subjects as bad in the single trial data table. Add a new column `bad`
  # to `all_data`. This column is set to 1 if the participant is in the
  # bad_participants list, 0 if not
  all_data <- all_data %>%
    mutate(bad_mem_dp = if_else(participant %in% bad_dp$participant, 1, 0)) %>%
    mutate(bad_catch  = if_else(participant %in% bad_catch$participant, 1, 0))
  
  return(list(all_data = all_data, summary_mem_accuracy = summary_mem_accuracy))
  
}