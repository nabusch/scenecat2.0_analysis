fn_summarize_cat_accuracy <- function(all_data, vars){
 
# Select data from: categorization task, only within RT range.

  #This computes the false alarm rate grouped by typicality. i don't think this
  #makes sense, so the code below computes the FAR collapsed across typicaliy
  #bins.
  
  #summary_cat_accuracy <- all_data %>% filter(task == "categorization")
  #%>% filter(cat_rt < vars$cat_rt_max) %>% filter(cat_rt > vars$cat_rt_min) %>%
  #filter(category %in% vars$categories) %>% group_by(participant, typi_bin,
  #category) %>% summarize( ntrials_cat = n(), cat_hitr = (sum(cat_corr == 1 &
  #cond_cat == "target", na.rm = TRUE)+0.5)     / (sum(cond_cat == "target",
  #na.rm = TRUE)+1), cat_falr = (sum(cat_corr == 0 & cond_cat == "distractor",
  #na.rm = TRUE)+0.5) / (sum(cond_cat == "distractor", na.rm = TRUE)+1), .groups
  #= 'drop' # Drop the automatic grouping to avoid issues later ) %>% mutate(
  #cat_dprime = qnorm(cat_hitr) - qnorm(cat_falr), cat_crit   = -0.5 *
  #(qnorm(cat_hitr) + qnorm(cat_falr)) )
  
  
  summary_cat_accuracy <- all_data %>%
    filter(task == "categorization") %>%
    filter(cat_rt < vars$cat_rt_max) %>%
    filter(cat_rt > vars$cat_rt_min) %>%
    filter(category %in% vars$categories) %>%
    group_by(participant, typi_bin, category) %>%
    mutate(
      cat_falr = (sum(cat_corr == 0 & cond_cat == "distractor", na.rm = TRUE) + 0.5) / (sum(cond_cat == "distractor", na.rm = TRUE) + 1)
    ) %>%
    ungroup() %>%
    group_by(participant, typi_bin, category) %>%
    summarize(
      ntrials_cat = n(),
      cat_hitr = (sum(cat_corr == 1 & cond_cat == "target", na.rm = TRUE) + 0.5)    / (sum(cond_cat == "target", na.rm = TRUE) + 1),
      cat_falr = first(cat_falr),  # Use the precomputed cat_falr
      .groups = 'drop'
    ) %>%
    mutate(
      cat_dprime = qnorm(cat_hitr) - qnorm(cat_falr),
      cat_crit   = -0.5 * (qnorm(cat_hitr) + qnorm(cat_falr))
    )
  
  
  return(summary_cat_accuracy) 
}