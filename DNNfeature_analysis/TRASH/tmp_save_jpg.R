# ------------------------------------------------------------------------------  
library(jpeg)
# Define output file path
output_file <- file.path(params$output_dir, paste0("Extreme_Images_", params$dist_metric, ".jpg"))

# Save plot as JPG
jpeg(output_file, width = 2000, height = 1500, res = 300)

# Display the final plot with the title
grid.newpage()
grid.draw(arrangeGrob(title, final_plot, ncol = 1, heights = c(0.1, 1)))

# Close the graphics device to save the file
dev.off()

# Print confirmation message
message("Plot saved to: ", output_file)
