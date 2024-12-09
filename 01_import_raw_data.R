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


# We need to code where a given dataset was collected. This is not coded in
# thePsychopy logfiles, but we can infer it from certain columns that are unique
# to the Prague/Muenster version.
vars$place_strings <- list(
  "vpcode" = "Muenster",
  "email for compensation" = "Prague"
)

# The German version of this experiment has some columns named in German. Wie
# need to rename these columns for consistency with the English version.
vars$column_renames <- c("Alter"       = "Age", 
                         "Geschlecht"  = "Gender", 
                         "Haendigkeit" = "Handedness")

vars$columns_of_interest <- c("participant", "age", "gender", "handed", "place",
                              "task",
                              "target_cat", "cond_cat", "cat_key", "cat_corr", "cat_rt", 
                              "cond_mem", "mem_response",
                              "typicality", "conceptual", "perceptual",  "category", "stimulus"
                              )


# Where is all this stuff located? My folder structure is:
# 2024_scenecat2.0
# ├───code
# │   └───scenecat2.0_analysis
# │       └───functions
# └───data
#         ├───data_muenster
#         ├───data_muenster_pilot
#         └───data_prague

dirs <- list()
dirs$main       <- "C:/Users/nbusch/sciebo_box_projects/Projects/2024_scenecat2.0/"
dirs$functions  <- paste0(dirs$main, "/code/scenecat2.0_analysis/functions/")
dirs$data       <- paste0(dirs$main, "/data/")
dirs$logfiles   <- paste0(dirs$data, "/data_muenster_pilot/")
# dirs$logfiles   <- paste0(dirs$data, "/data_muenster/")
# dirs$logfiles   <- paste0(dirs$data, "/data_prague/")


# === Read the log files. ======================================================

# Get a list of logfiles to process.
source(file.path(dirs$functions, "fn_list_logfiles.R"))
logfile_list <- fn_list_logfiles(dirs, "SceneCat_2023")

# Get an overview of our datasets.
source(file.path(dirs$functions, "fn_logfile_overview.R"))
logfile_overview <- fn_logfile_overview(logfile_list, vars, dirs)

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
