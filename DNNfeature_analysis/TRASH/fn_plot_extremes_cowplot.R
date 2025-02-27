library(ggplot2)
library(cowplot)
library(dplyr)
library(purrr)
library(png)

# Function to extract and visualize extreme images using cowplot
fn_plot_extremes <- function(df_sim, dist_metric, n_extremes, params) {
  
  source("fn_load_image.R")  # Load image function
  
  message("Extracting extreme values...")
  
  # Extract extreme values efficiently
  extremes <- df_sim %>%
    select(stimulus, category, !!sym(dist_metric)) %>%
    rename(distm = !!sym(dist_metric)) %>%
    group_by(category) %>%
    summarise(
      min_images = list(stimulus[order(distm)][1:n_extremes]),
      max_images = list(stimulus[order(desc(distm))][1:n_extremes]),
      min_vals = list(distm[order(distm)][1:n_extremes]),
      max_vals = list(distm[order(desc(distm))][1:n_extremes]),
      .groups = "drop"
    )
  
  message("Loading images...")
  
  # Load images
  extremes <- extremes %>%
    mutate(
      min_imgs = map(min_images, ~ map(.x, fn_load_image, params)),
      max_imgs = map(max_images, ~ map(.x, fn_load_image, params))
    )
  
  message("Creating plot...")
  
  # Function to create an image plot with a value label
  create_image_plot <- function(img, val) {
    if (is.null(img)) {
      return(ggplot() + theme_void())  # Empty plot for missing images
    }
    
    ggdraw() + 
      draw_image(img) +
      draw_label(format(val, digits = 3), x = 0.5, y = 0.1, color = "white", size = 12)
  }
  
  # Generate plots for each category
  category_plots <- pmap(extremes, function(category, min_imgs, max_imgs, min_vals, max_vals, ...) {
    
    category_title <- ggdraw() + draw_label(category, fontface = "bold", size = 14)
    
    # Create lists of plots for min and max images
    min_plots <- map2(min_imgs, min_vals, create_image_plot)
    max_plots <- map2(max_imgs, max_vals, create_image_plot)
    
    # Combine into a single row
    plot_row <- plot_grid(plotlist = c(min_plots, max_plots), nrow = 1)
    
    # Combine title + images
    plot_grid(category_title, plot_row, ncol = 1, rel_heights = c(0.1, 1))
  })
  
  # Combine all categories into one figure
  final_plot <- plot_grid(plotlist = category_plots, ncol = 1)
  title_plot <- ggdraw() + draw_label(paste("Extreme Images Based on", dist_metric), fontface = "bold", size = 16)
  
  # Combine title + all categories
  full_plot <- plot_grid(title_plot, final_plot, ncol = 1, rel_heights = c(0.1, 1))
  
  # Display the final plot
  dev.new()
  
  print(full_plot)
  
  message("Plotting complete.")
}
