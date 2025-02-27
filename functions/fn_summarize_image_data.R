fn_summarize_image_data <- function(prep_data, vars){
  
  
  summary_img_cat_rt <- prep_data %>%
    mutate(stimulus = as.factor(stimulus)) %>%
    filter(task     == "categorization") %>%
    filter(cond_cat == "target") %>%
    filter(cat_corr == 1) %>%
    filter(cat_rt < vars$cat_rt_max) %>%
    filter(cat_rt > vars$cat_rt_min) %>%
    filter(category %in% vars$categories) %>%
    group_by(stimulus) %>%
    summarize(
      category = first(category),
      r_typicality = first(r_typicality),
      ntrials_rt = n(),
      img_cat_rt = mean(cat_rt, na.rm = TRUE),
      .groups = 'drop' # Drop the automatic grouping to avoid issues later
    ) %>%
    mutate(rt_log = log(img_cat_rt))
  
  
  summary_img_mem_accuracy <- prep_data %>%
    mutate(stimulus = as.factor(stimulus)) %>%
    filter(task == "memory") %>%
    filter(category %in% vars$categories) %>%
    group_by(stimulus) %>%
    summarize(
      ntrials_mem   = n(),
      ntrials_old  = sum(cond_mem == "old"),
      ntrials_new  = sum(cond_mem == "new"),
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
  
  compute_accuracy <- function(cond_mem, mem_response) {
    score <- case_when(
      cond_mem == "old" & mem_response == "sure old" ~ 1,
      cond_mem == "old" & mem_response == "maybe old" ~ 0.5,
      cond_mem == "old" & mem_response == "maybe new" ~ -0.5,
      cond_mem == "old" & mem_response == "sure new" ~ -1,
      cond_mem == "new" & mem_response == "sure new" ~ 1,
      cond_mem == "new" & mem_response == "maybe new" ~ 0.5,
      cond_mem == "new" & mem_response == "maybe old" ~ -0.5,
      cond_mem == "new" & mem_response == "sure old" ~ -1,
      TRUE ~ 0  # default case if none of the above match
    )
    return(score)
  }
  
  summary_img_confidence <- prep_data %>%
    mutate(stimulus = as.factor(stimulus)) %>%
    filter(task == "memory") %>%
    filter(category %in% vars$categories) %>%
    mutate(score = mapply(compute_accuracy, cond_mem, mem_response)) %>%
    group_by(stimulus) %>%
    summarize(conf_score = mean(score))
  
  summary_img <- full_join(summary_img_cat_rt, summary_img_mem_accuracy, by = "stimulus")
  summary_img <- full_join(summary_img, summary_img_confidence, by = "stimulus")
  
  
  return(summary_img)
  
}