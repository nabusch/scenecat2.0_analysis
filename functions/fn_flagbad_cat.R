fn_flagbad_cat <- function(summary_cat_accuracy, summary_cat_rt_target, all_data, vars){
  
  # Identify bad participants:
  # - If their cat. d' is lower than critical value.
  # - If their number of trials is lower than critical value.
  
  bad_participants_accuracy <- summary_cat_accuracy %>%
    group_by(participant, typi_bin) %>%
    summarize(
      cat_dprime = first(cat_dprime),  
      is_bad_cat_acc = any(cat_dprime < vars$cat_dprime_min | ntrials_cat < vars$cat_ntrials_min),
      .groups = 'drop' # Drop the automatic grouping to avoid issues later
    ) %>% filter(is_bad_cat_acc) 
  
  bad_participants_rt <- summary_cat_rt_target %>%
    group_by(participant, typi_bin) %>%
    summarize(
      ntrials_rt = first(ntrials_rt_target),  
      is_bad_cat_rt = any(ntrials_rt < vars$cat_ntrials_min),
      .groups = 'drop' # Drop the automatic grouping to avoid issues later
    ) %>% filter(is_bad_cat_rt) 

  # Update the summary data.
  summary_cat_accuracy <- summary_cat_accuracy %>%
    mutate(bad_cat_acc = if_else(participant %in% bad_participants_accuracy$participant, 1, 0))
  
  summary_cat_rt_target <- summary_cat_rt_target %>%
    mutate(bad_cat_rt  = if_else(participant %in% bad_participants_rt$participant, 1, 0))
  
  # Flag subjects as bad in the single trial data table. Add a new column `bad`
  # to `all_data`. This column is set to 1 if the participant is in the
  # bad_participants list, 0 if not
  all_data <- all_data %>%
    mutate(bad_cat = if_else(participant %in% bad_participants_accuracy$participant | participant %in% bad_participants_rt$participant, 1, 0))
  
  return(list(all_data = all_data, summary_cat_accuracy = summary_cat_accuracy, summary_cat_rt_target = summary_cat_rt_target))
  
}