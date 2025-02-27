fn_summarize_cat_rt <- function(prep_data, vars){


# Select data from: categorization task, only target, only correct, only within RT range.
  summary_cat_rt_target <- prep_data %>%
    filter(task     == "categorization") %>%
    filter(cond_cat == "target") %>%
    filter(cat_corr == 1) %>%
    filter(cat_rt < vars$cat_rt_max) %>%
    filter(cat_rt > vars$cat_rt_min) %>%
    filter(category %in% vars$categories) %>%
    group_by(participant, typi_bin, category) %>%
    summarize(
      ntrials_rt_target = n(),
      cat_rt_target = mean(cat_rt, na.rm = TRUE),
      .groups = 'drop' # Drop the automatic grouping to avoid issues later
    )

  # Select data from: categorization task, only DISTRACTORS, only correct, only within RT range.
  # Step 1: Filter and complete the data to include all combinations
  data_complete <- prep_data %>%
    filter(task == "categorization") %>%
    filter(cond_cat == "distractor") %>%
    filter(cat_corr == 1) %>%
    filter(cat_rt < vars$cat_rt_max) %>%
    filter(cat_rt > vars$cat_rt_min) %>%
    filter(category %in% vars$categories) %>%
    complete(participant, typi_bin, category)

  # Step 2: Summarize the completed data
  summary_cat_rt_distractor <- data_complete %>%
    group_by(participant, typi_bin, category) %>%
    summarize(
      ntrials_rt_distractor = n(),
      cat_rt_distractor = mean(cat_rt, na.rm = TRUE),
      .groups = 'drop'
    )

  # Combine the two summaries

  # Combine the two summaries by merging on common columns
  #summary_cat_rt <- summary_cat_rt_target %>%
   # full_join(summary_cat_rt_distractor, by = c("participant", "typi_bin", "category"))

  #summary_cat_rt <- summary_cat_rt_target
  
  
  return(list(summary_cat_rt_target = summary_cat_rt_target, summary_cat_rt_distractor = summary_cat_rt_distractor) )
}