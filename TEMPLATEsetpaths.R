setpaths <- function(vars){
  
  dirs <- list()
  
  # Where is all this stuff located? My folder structure is:
  # 2024_scenecat2.0
  # ├───code
  # │   └───scenecat2.0_analysis
  # │       └───functions
  # └───data
  #         ├───data_muenster
  #         ├───data_muenster_pilot
  #         └───data_prague
  
  # The main folder of this project where the code is located.
  dirs$main       <- "C:/Users/nbusch/sciebo_box_projects/Projects/2024_scenecat2.0/"
  
  # Sub-folder where I put all the sub-functions.
  dirs$functions  <- paste0(dirs$main, "/code/scenecat2.0_analysis/functions/")
  
  # The top-level folder where the data are located. We have different
  # sub-folders for the logfiles collected in Münster and Prague.
  dirs$data       <- paste0(dirs$main, "/data/")
  
  dirs$logfiles   <- paste0(dirs$data, "/data_muenster_pilot/")
  # dirs$logfiles   <- paste0(dirs$data, "/data_muenster/")
  dirs$logfiles   <- paste0(dirs$data, "/data_prague/") 
  
  
  # Function to check existence and print message
  check_directory_existence <- function(dir_path, dir_name) {
    if (file.exists(dir_path)) {
      message(paste0("Directory '", dir_name, "' exists at path:", dir_path))
    } else {
      message(paste0("Directory '", dir_name, "' does NOT exist at path:", dir_path))
    }
  }
  
  # Iterate over each directory and check existence
  for (dir_name in names(dirs)) {
    check_directory_existence(dirs[[dir_name]], dir_name)
  }
  
  return(dirs)
}