# ------------------------------------------------------------------------------
# Load necessary libraries and set parameters.
# ------------------------------------------------------------------------------
library(tidyverse)
library(zeallot) # Enables multiple outputs from functions, almost Matlab style.

params                     <- list()
params$csv_name            <- "scenecat2.0_feature_combination.csv"
params$dir_csv             <- r"(C:\Users\nbusch\sciebo_box_projects\Projects\2024_scenecat_2.0\code\scenecat2.0_analysis\DNNfeature_analysis)"
params$dir_img             <- r"(C:\Users\nbusch\sciebo_box_projects\Projects\2024_scenecat_2.0\code\scenecat2.0_analysis\DNNfeature_analysis\stimuli)"
params$dnn_features_prefix <- "V" # Variables coding DNN features have this prefix. 
params$pca_exvar           <- 0.95 # Extract n PCA components explaining so much total variance.
params$pca_prefix          <- "PC"
params$bad_imgs            <- c("img_cnyac", "img_d0k76", "img_89rmb", "img_aplao", "img_9jgbc", "img_jp28n", "img_ccn2w", "img_5jy9c")

# ------------------------------------------------------------------------------
# Load and prepare the data.
# ------------------------------------------------------------------------------
source("./functions/fn_read_feature_csv.R")
df_features <- fn_read_feature_csv(params)

source("./functions/fn_prep_data.R")
info <- list() # we will use this list to store meta data.
c(df_features, info) %<-% fn_prep_data(df_features, params, info) 


# ------------------------------------------------------------------------------
# Run PCA
# ------------------------------------------------------------------------------
source("./functions/fn_run_pca.R")
c(df_pca, info) %<-% fn_run_pca(df_features, params, info) 


# ------------------------------------------------------------------------------
# Compute similarity metrics.
# ------------------------------------------------------------------------------
params$features_do_log    <- FALSE
params$features_do_center <- TRUE
params$features_do_scale  <- TRUE

# Taking log, and not z-scoring corresponds to Murdock's procedure for computing distinctiveness. 
# params$features_do_log    <- TRUE
# params$features_do_center <- FALSE
# params$features_do_scale  <- FALSE

params$sim_feature        <- "pca" 
# params$sim_feature = "pca"/"dnn"/"human": compute the similarity metrics based
# on PCA or DNN or human features. Note: when using dnn features, we have to
# switch off the scaling inside the # analyze_image_similarity_weighted
# function, or else there will be lots of nans. # Not sure why this happens, I
# suspect some dnn features have no standard deviation and thus produce nans at
# z-scoring.

df_sim <- df_pca
methods <- c("correlation", "cosine", "dotproduct", "euclidean", "manhattan")

source("./functions/fn_feature_similarity.R")

for (imeth in methods) { 
  df_sim <- fn_feature_similarity(df_sim, info, sim_method = imeth)
}


# ------------------------------------------------------------------------------
# Scatter plot, correlating behavioral performance and similarity metrics.
# ------------------------------------------------------------------------------
plot_metrics <- paste0(methods, "_similar")
plot_metrics <- paste0(methods, "_distnct")

dependent_vars <- c("img_cat_rt", "mem_dprime", "mem_crit", "r_typicality")

source("./functions/plot_similarity_scatter.R")
plot_similarity_scatter(df_sim, plot_metrics, dependent_vars)


# ------------------------------------------------------------------------------
# Show examples of most extreme images.
# ------------------------------------------------------------------------------
source("./functions/fn_plot_extremes.R")
n_extremes <- 4
fn_plot_extremes(df_sim, "dotproduct_distnct", n_extremes, params)

