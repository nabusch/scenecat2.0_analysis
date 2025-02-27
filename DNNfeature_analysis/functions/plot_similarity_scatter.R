plot_similarity_scatter <- function(df_sim, sim_metrics, dependent_vars){
  
  # ----------------------------------------------------------------------------
  # Load necessary libraries
  # ----------------------------------------------------------------------------
  require(tidyverse)
  require(ggplot2)
  require(patchwork)  # For arranging multiple plots

  
  # ----------------------------------------------------------------------------
  # Create an empty list to store plots
  # ----------------------------------------------------------------------------
  plot_list <- list()
  
  
  # ----------------------------------------------------------------------------
  # Loop through dependent variables (rows) and metrics (columns)
  # ----------------------------------------------------------------------------
  for (metric in sim_metrics) {
    for (dep_var in dependent_vars) {
      
      # Compute correlation coefficient
      correlation_value <- cor(df_sim[[metric]], df_sim[[dep_var]], use = "complete.obs")
      
      # Create scatter plot
      p <- ggplot(df_sim, aes_string(x = metric, y = dep_var, color = "category")) +
        geom_point(alpha = 0.7) +
        labs(
          title = paste(dep_var, "vs", metric),
          subtitle = paste("Correlation:", round(correlation_value, 2))
        )  + 
        theme_minimal()+
        theme(legend.position = "bottom")
      
      # Store the plot
      plot_list[[paste(dep_var, metric)]] <- p
    }
  }
  
  
  # ----------------------------------------------------------------------------
  # Display the final plot
  # ----------------------------------------------------------------------------
  final_plot <- wrap_plots(plot_list, 
                           ncols = length(dependent_vars), ncols = length(sim_metrics),
                           byrow = FALSE)
  dev.new()
  print(final_plot)
}
