# ==============================================================================
# This script reads in the raw .csv files that were produced by Psychopy. These
# files have terrible formatting and include a lot of data that is not relevant
# for our analysis. We import these files and transform them into a data frame
# with one line per trial.

rm(list = ls(all.names = TRUE))

library(pacman)
p_load(dplyr, tidyr, stringr, readr)


# Define all variable decisions of this analysis.
vars                      <- list()
vars$exp_name             <- "scenecat_2.0"

vars$min_logfile_kbsize   <- 50 # some logfiles do not include all metadata (probably because the experiment was immediately interrupted). this makes the code crash. we need to exclude these files.

# We need to code where a given dataset was collected. This is not coded in
# the Psychopy logfiles, but we can infer it from certain columns that are unique
# to the Prague/Muenster version.
vars$place_strings       <- list(
  "vpcode" = "Muenster",
  "email"  = "Prague"
)

# The German version of this experiment has some columns named in German. Wie
# need to rename these columns for consistency with the English version.
vars$column_renames      <- c("Alter"       = "age", 
                              "Geschlecht"  = "gender", 
                              "Haendigkeit" = "handedness")

vars$columns_of_interest <- c("participant", "age", "gender", "handed", "place",
                              "task",
                              "target_cat", "cond_cat", "cat_key", "cat_corr", "cat_rt", 
                              "cond_mem", "mem_response", "mem_perform",
                              "typicality", "conceptual", "perceptual",  "category", "stimulus"
)

# ATTENTION: when you first clone this repository, you need to edit the content
# of the file TEMPLATEsetpaths.R as follows:
#
# - Open the script and edit all the directory names to match your local directory structure.
# - Then save the script under setpath.R, i.e. omitting the "TEMPLATE" prefix.
#
# The rationale is that every user will have a different directory structure,
# but we do not want to push and pull everyone's local settings back and forth
# between each other. I have included the file "setpaths.R" in the .gitignore
# list, so your local setpaths.R script will not be tracked and synced by Git.
source("setpaths.R")
dirs <- setpaths()



# === Read the log files. ======================================================

# Get a list of logfiles to process.
source(file.path(dirs$functions, "fn_list_logfiles.R"))
logfile_list <- fn_list_logfiles(dirs, vars, "SceneCat")

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
