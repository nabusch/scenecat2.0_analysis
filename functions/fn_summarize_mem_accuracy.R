fn_summarize_mem_accuracy <- function(all_data, vars){
  
  summary_mem_accuracy <- all_data %>%
    filter(task == "memory") %>%
    filter(category %in% vars$categories) %>%
    group_by(participant, typi_bin, category) %>%
    summarize(
      ntrials_mem = n(),
      n_catch = first(n_catch), 
      mem_hitr      = (sum(mem_perform == "hit" , na.rm = TRUE)+0.5) / (sum(cond_mem == "old", na.rm = TRUE)+1),
      mem_falr      = (sum(mem_perform == "fa" , na.rm = TRUE)+0.5)  / (sum(cond_mem == "new", na.rm = TRUE)+1),
      mem_hit_conf  = (sum(mem_response_num[cond_mem == "old"], na.rm = TRUE) + 0.5) / (sum(cond_mem == "old", na.rm = TRUE) + 1),
      mem_fal_conf  = (sum(mem_response_num[cond_mem == "new"], na.rm = TRUE) + 0.5) / (sum(cond_mem == "new", na.rm = TRUE) + 1),
      .groups = 'drop' # Drop the automatic grouping to avoid issues later
    ) %>%
    mutate(
      mem_dprime      = qnorm(mem_hitr) - qnorm(mem_falr),
      mem_crit        = -0.5 * (qnorm(mem_hitr) + qnorm(mem_falr)),
      mem_dprime_conf = qnorm(mem_hit_conf) - qnorm(mem_fal_conf),
      mem_crit_conf   = -0.5 * (qnorm(mem_hit_conf) + qnorm(mem_fal_conf))
    )
  
  return(summary_mem_accuracy) 
}  
