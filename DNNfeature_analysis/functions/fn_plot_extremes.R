
  # Function to extract and visualize extreme images
  fn_plot_extremes <- function(df_dist, dist_metric, n_extremes, params) {
    
    require(ggplot2)
    require(grid)
    require(gridExtra)
    require(png)
    require(dplyr)
    require(purrr)
    
    source("./functions/fn_load_image.R")
    
    
    message("Extracting extreme values...")
    
    # Extract extreme values efficiently
    extremes <- df_dist %>%
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
    
    # Generate image grid layout
    image_grobs <- pmap(extremes, function(category, min_imgs, max_imgs, min_vals, max_vals, ...) {
      
      category_label <- textGrob(category, gp = gpar(fontsize = 14, fontface = "bold"))
      
      create_image_grob <- function(img, val) {
        if (is.null(img)) return(nullGrob())
        img_grob <- rasterGrob(img)
        label_grob <- textGrob(format(val, digits = 3), gp = gpar(fontsize = 12, col = "white"))
        gTree(children = gList(img_grob, label_grob))
      }
      
      # Create rows for min and max images
      min_grobs <- map2(min_imgs, min_vals, create_image_grob)
      max_grobs <- map2(max_imgs, max_vals, create_image_grob)
      
      arrangeGrob(
        grobs = c(list(category_label), min_grobs, max_grobs),
        ncol = 1 + 2 * n_extremes,
        widths = c(1, rep(3, 2 * n_extremes))
      )
    })
    
    # Arrange all category rows
    final_plot <- do.call(arrangeGrob, c(image_grobs, ncol = 1))
    title <- textGrob(paste("Extreme Images Based on", dist_metric), gp = gpar(fontsize = 16, fontface = "bold"))
    
    # Display the final plot
    dev.new()
    grid.newpage()
    grid.draw(arrangeGrob(title, final_plot, ncol = 1, heights = c(0.1, 1)))
    
    message("Plotting complete.")
  }
  
  