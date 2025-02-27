# Plot images
fn_plot_images <- function(category, min_img, max_img, min_name, max_name) {
  if (!is.null(min_img) & !is.null(max_img)) {
    grid.arrange(
      rasterGrob(min_img), rasterGrob(max_img),
      ncol = 2,
      top = paste("Category:", category, "\nMin:", min_name, "| Max:", max_name)
    )
  }
}