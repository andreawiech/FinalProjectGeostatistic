# import libaries
library("stars")
library("ggplot2") # only for viewing; package is ggplot2, command is ggplot()

#to create the datatframe
library(dplyr)
library(lubridate)
library(ncdf4)

# set working directory
#setwd("C:/Users/andre/OneDrive/Dokumente/UNI/Master_Semester_2/Geostatistics/FinalProject")
setwd("/Users/sschimpfle/Atmospärenwissenschaften/Geostatistic/Final_Project/FinalProjectGeostatistic")
# GADM Data
autBoundaries <- read_sf("gadm41_AUT_2.json")
plot(st_geometry(autBoundaries)) # plot view base R
ggplot() + geom_sf(data = autBoundaries, fill = "lightblue") # plot in "tidyverse"

#To extract a state, e.g. Tirol, and:
tirol <- subset(autBoundaries, NAME_1 == "Tirol")
# plot tirol
plot(st_geometry(tirol)) # plot view base R
ggplot() + geom_sf(data = tirol, fill = "lightblue") # plot in "tidyverse"

# SRTM Data
# Listing all unzipped srtm_*.tif files
files <- list.files()
files <- files[grepl("srtm_.*.tif$", files)]
print(files)

tmp <- lapply(files, read_stars)

dem <- do.call(st_mosaic, tmp)
st_crs(dem) <- st_crs(4326) # Adding lonlat coordinate reference
plot(dem)

#Import the snowdepth data:
data <- read.csv("snowdepth_data/AKLE2_HS_2023_2024.csv",header = FALSE ,sep = ";")
head(data)

# Extract metadata
station_location <- data[1,2]
station_name <- data[2,2]
station_number <- data[3,2]
station_altitude <- as.numeric(data[4, 2])
latitude <- as.numeric(gsub(",", ".", data[14, 2]))
longitude <- as.numeric(gsub(",", ".", data[13,2]))

# Skip the first 32 rows (metadata) and rename columns
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

# Display the cleaned data
head(data_clean)

###################################
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

# Display the combined data
head(tirolSnowdepth)
#View(tirolSnowdepth)
stations <- unique(tirolSnowdepth$station_name)
stations


######## the radiation data

nc_file <- nc_open("apolis.nc")

# Print the NetCDF file summary
print(nc_file)

# Get the variable names
variables <- names(nc_file$var)
print(variables)

# Read a specific variable (replace 'varname' with actual variable name)
var_data <- ncvar_get(nc_file, "GLO_real_daysum_kWh")

# Close the NetCDF file
nc_close(nc_file)

# Display the variable data
head(var_data)
