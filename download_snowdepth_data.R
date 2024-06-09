# specify URL where file is stored
url <- "https://wiski.tirol.gv.at/lawine/produkte/ogd/.*._HS_.*.csv$"

# Specify destination where file should be saved
destfile <- "C:/Users/andre/OneDrive/Dokumente/UNI/Master_Semester_2/Geostatistics/FinalProject/snowdepth_data"

# Apply download.file function in R
download.file(url, destfile)


library(rvest)
library(dplyr)

# Base URL to scrape
base_url <- "https://wiski.tirol.gv.at/lawine/produkte/ogd/"

# Directory to save the files
save_dir <- "C:/Users/andre/OneDrive/Dokumente/UNI/Master_Semester_2/Geostatistics/FinalProject/snowdepth_data"


# Function to download a file
download_file <- function(url, save_dir) {
  # Extract the file name from the URL
  file_name <- basename(url)
  # Create the full path to save the file
  dest_file <- file.path(save_dir, file_name)
  # Download the file
  download.file(url, destfile = dest_file, mode = "wb")
  cat("Downloaded:", file_name, "\n")
}

# Create the directory if it doesn't exist
if (!dir.exists(save_dir)) {
  dir.create(save_dir)
}

# Function to scrape and download CSV files containing '_HS_' in their names
scrape_and_download_csvs <- function(base_url, save_dir) {
  # Read the HTML content from the base URL
  page <- read_html(base_url)
  
  # Extract all links from the page
  links <- page %>%
    html_nodes("a") %>%
    html_attr("href") %>%
    na.omit() %>%
    unique()
  
  # Filter links that contain '_HS_' and end with '.csv'
  csv_links <- links %>%
    grep("_HS_.*\\.csv$", ., value = TRUE)
  
  # Create the full URLs
  full_urls <- paste0(base_url, csv_links)
  
  # Loop through each URL and download the file
  for (url in full_urls) {
    download_file(url, save_dir)
  }
}

# Run the scraping and downloading function
scrape_and_download_csvs(base_url, save_dir)

