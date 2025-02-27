# Function to load an image file

fn_load_image <- function(filename, params) {
  file_path <- file.path(params$dir_img, filename)
  
  if (file.exists(file_path)) {
    if (grepl("\\.jpg$", filename, ignore.case = TRUE)) {
      return(readJPEG(file_path))
    } else if (grepl("\\.png$", filename, ignore.case = TRUE)) {
      return(readPNG(file_path))
    }
  } else {
    message("File not found: ", file_path)
    return(NULL)
  }
}
