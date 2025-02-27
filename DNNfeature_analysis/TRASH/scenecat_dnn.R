# ------------------------------------------------------------------------------
# Load necessary libraries and set parameters.
# ------------------------------------------------------------------------------
library(tidyverse)
library(zeallot) # Enables multiple outputs from functions, almost Matlab style.

params                     <- list()
# params$csv_name            <- "scenecat2.0_combined_features.csv"
params$csv_name            <- "scenecat2.0_feature_combination.csv"
params$dir_csv             <- r"(C:\Users\nbusch\sciebo_box_projects\Projects\2024_scenecat_2.0\code\scenecat2.0_analysis\DNNfeature_analysis)"
params$dir_img             <- r"(C:\Users\nbusch\sciebo_box_projects\Projects\2024_scenecat_2.0\code\scenecat2.0_analysis\DNNfeature_analysis\stimuli)"
params$dnn_features_prefix <- "V" # Variables coding DNN features have this prefix. 
params$dnn_features_idx    <- 1:4096 # We have so many DNN features.
params$pca_exvar           <- 0.82 # Extract n PCA components explaining so much total variance.
params$pca_prefix          <- "PC"
params$bad_imgs            <- c("img_cnyac", "img_d0k76", "img_89rmb", "img_aplao", "img_9jgbc", "img_jp28n", "img_ccn2w", "img_5jy9c")

# ------------------------------------------------------------------------------
# Load and prepare the data.
# ------------------------------------------------------------------------------
source("fn_read_feature_csv.R")
df_features <- fn_read_feature_csv(params)

source("fn_prep_data.R")
info <- list() # we will use this list to store meta data.
c(df_features, info) %<-% fn_prep_data(df_features, params, info) 


# ------------------------------------------------------------------------------
# Run PCA
# ------------------------------------------------------------------------------
source("fn_run_pca.R")
c(df_pca, info) %<-% fn_run_pca(df_features, params, info) 


# ------------------------------------------------------------------------------
# Compute similarity metrics.
# ------------------------------------------------------------------------------
params$sim_pca_dnn        <- "pca" # "pca"/"dnn"/"human": compute the
# distinctiveness metrics based on PCA or DNN features. # Note: when using dnn
# features, we have to switch off the scaling inside the #
# analyze_image_similarity_weighted function, or else there will be lots of
# nans. # Not sure why this happens, I suspect some dnn features have no
# standard deviation and thus produce nans at z-scoring.

df_sim <- df_pca
methods <- c("correlation", "cosine", "dotproduct", "euclidean", "manhattan")

source("analyze_image_similarity_weighted2.R")
source("analzye_image_euclideandist.R")

for (imeth in methods) { 
  df_sim <- analyze_image_similarity_weighted2(df_sim, info, sim_method = imeth)
}
# df_dist <- analzye_image_euclideandist(df_dist, info)


# ------------------------------------------------------------------------------
# Scatter plot, correlating behavioral performance and distinctiveness metrics.
# ------------------------------------------------------------------------------
sim_metrics <- c("sim_corr", "sim_dot", "sim_cosim", "sim_eukl", "sim_manhattan")
#sim_metrics <- c("dist_corr_weighted", "dist_dot_weighted", "dist_cosim_weighted", "dist_eukl_weighted")
dependent_vars <- c("img_cat_rt", "mem_dprime", "mem_crit", "r_typicality")

source("plot_similarity_scatter.R")
plot_similarity_scatter(df_sim, sim_metrics, dependent_vars)


# ------------------------------------------------------------------------------
# Show examples of most extreme images.
# ------------------------------------------------------------------------------
source("fn_plot_extremes.R")
n_extremes <- 4
# fn_plot_extremes(df_dist, "dist_corr", n_extremes, params)
fn_plot_extremes(df_dist, "dist_dot", n_extremes, params)
fn_plot_extremes(df_dist, "dist_eukl", n_extremes, params)

