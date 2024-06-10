# import libaries
library("stars")
#to create the datatframe
library(dplyr)
library(lubridate)
library(stars)
library(mgcv)

#setwd("C:/Users/andre/OneDrive/Dokumente/UNI/Master_Semester_2/Geostatistics/FinalProject")
setwd("/Users/sschimpfle/Atmospärenwissenschaften/Geostatistic/Final_Project/FinalProjectGeostatistic")
# List all CSV files in the directory
files <- list.files("snowdepth_data", pattern = "*.csv$", full.names = TRUE)

# Initialize an empty list to store data frames
all_data <- list()

# Function to clean and structure a single CSV file
process_file <- function(file) {
  # Read the CSV file
  data <- read.csv(file, header = FALSE, sep = ";", stringsAsFactors = FALSE)
  
  # Extract metadata
  station_location <- data[1, 2]
  station_name <- data[2, 2]
  station_number <- data[3, 2]
  station_altitude <- as.numeric(data[4, 2])
  latitude <- as.numeric(gsub(",", ".", data[14, 2]))
  longitude <- as.numeric(gsub(",", ".", data[13, 2]))
  
  # Skip the first 16 rows (metadata) and rename columns
  data_clean <- data[-c(1:16), ]
  colnames(data_clean) <- c("date_time", "snow_depth")
  
  # Convert date_time column to POSIXct type and snow_depth to numeric
  data_clean$date_time <- dmy_hms(data_clean$date_time)
  data_clean$snow_depth <- as.numeric(gsub(",", ".", data_clean$snow_depth))
  
  # Add the metadata columns to the data frame
  data_clean <- data_clean %>%
    mutate(
      station_location = station_location,
      station_name = station_name,
      station_number = station_number,
      latitude = latitude,
      longitude = longitude,
      station_altitude = station_altitude
    )
  
  return(data_clean)
}

# Apply the function to each file and combine the results
all_data <- lapply(files, process_file)
tirolSnowdepth <- bind_rows(all_data)

saveRDS(tirolSnowdepth, "tirolSnowdepth.rds")
write.csv(tirolSnowdepth, "tirolSnowdepth.csv", row.names = FALSE)
# Display the combined data
head(tirolSnowdepth)
#View(tirolSnowdepth)
stations <- unique(tirolSnowdepth$station_name)
stations
Longitude <- unique(tirolSnowdepth$longitude)


Lattitude <- unique(tirolSnowdepth$latitude)

