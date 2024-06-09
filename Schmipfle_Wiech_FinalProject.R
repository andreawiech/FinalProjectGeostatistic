# import libaries
library("stars")
library("ggplot2") # only for viewing; package is ggplot2, command is ggplot()

# set working directory
setwd("C:/Users/andre/OneDrive/Dokumente/UNI/Master_Semester_2/Geostatistics/FinalProject")

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


