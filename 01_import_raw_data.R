# ==============================================================================
# This script reads in the raw .csv files that were produced by Psychopy. These
# files have terrible formatting and include a lot of data that is not relevant
# for our analysis. We import these files and transform them into a data frame
# with one line per trial.

rm(list = ls(all.names = TRUE))

library(pacman)
p_load(dplyr, tidyr, stringr, readr)


# Define all variable decisions of this analysis.
vars                     <- list()
vars$exp_name            <- "scenecat_2.0"

# The German version of this experiment has some columns named in German. Wie
# need to rename these columns for consistency with the English version.
vars$column_renames <- c("Alter"       = "Age", 
                         "Geschlecht"  = "Gender", 
                         "Haendigkeit" = "Handedness")

vars$columns_of_interest <- c("stimulus", "correct_answer",
                              "task",
                              "target_cat", "cond_cat", "cond_mem", "category", "typicality",
                              "p_typicality", "r_typicality", "conceptual", "perceptual",
                              "n", "cat_key", "cat_corr", "cat_rt", "mem_response",
                              "participant", "age", "gender", "handed")


# Where is all this stuff located?
dirs <- list()
dirs$main       <- "C:/Users/nbusch/sciebo_box_projects/Projects/2024_scenecat2.0/pilot"
dirs$functions  <- paste0(dirs$main, "/code/scenecat2.0_analysis/functions/")
dirs$logfiles   <- paste0(dirs$main, "/data/logfiles/")


# === Read the log files. ======================================================

# Get a list of logfiles to process.
source(file.path(dirs$functions, "fn_list_logfiles.R"))
logfile_list <- fn_list_logfiles(dirs, "SceneCat_2023")

# Get an overview of our datasets.
source(file.path(dirs$functions, "fn_logfile_overview.R"))
logfile_overview <- fn_logfile_overview(logfile_list, vars)

# Read all logfiles and append the raw data.
source(file.path(dirs$functions, "fn_import_read_logfiles.R"))
raw_data <- fn_import_read_logfiles(logfile_list, vars)

# Select only the data we are interested in a bring them into a coherent format.
source(file.path(dirs$functions, "fn_import_format_logfiles.R"))
all_data <- fn_import_format_logfiles(vars, raw_data)

# ==============================================================================
# Check to see how often each image was shown.
# stimulus_counts <- all_data %>%
#   count(stimulus, name = "count") %>%
#   arrange(desc(count)) # Optional: sort by the count in descending order
# 
# # Display the result
# stimulus_counts
