### GEOSPHERE APOLIS DOWNLOADER 
### Author: ChatGPT on behalf of A. Friesinger

import requests
from datetime import datetime, timedelta

# Define the start and end dates
start_date = datetime(2023, 11, 1)
end_date = datetime(2024, 3, 31)

# Loop through each date
current_date = start_date
while current_date <= end_date:
    # Format dates for URL parameters
    start_str = current_date.strftime('%Y-%m-%dT00:00')
    end_str = (current_date + timedelta(days=1)).strftime('%Y-%m-%dT00:00')
    
    # Create the URL
    url = (
        f"https://dataset.api.hub.geosphere.at/v1/grid/historical/apolis_short-v1-1d-100m"
        f"?parameters=GLO_real_daysum_kWh"
        f"&start={start_str}"
        f"&end={end_str}"
        f"&bbox=47.1,9.22,48.10,10.5"
        f"&output_format=netcdf"
        f"&filename=test"
    )
    
    # Define the filename
    filename = current_date.strftime('%Y-%m-%d') + '.nc'
    
    # Download the file
    response = requests.get(url)
    
    if response.status_code == 200:
        # Save the file
        with open(filename, 'wb') as file:
            file.write(response.content)
        print(f"Downloaded and saved: {filename}")
    else:
        print(f"Failed to download: {filename}. HTTP Status code: {response.status_code}")
    
    # Move to the next date
    current_date += timedelta(days=1)
	
	
	#### SECOND PART COMBINE ALL THE DAYLIY FILES
	
import xarray as xr
import glob	
	
	## combine all Files
## IF running in RAM issues combine smaller groups (monthwise, yearwise)
# Get a list of all the .nc files
file_list = sorted(glob.glob('202*.nc'))

# Load each NetCDF file individually and concatenate along the time dimension
datasets = [xr.open_dataset(file) for file in file_list]
combined_ds = xr.concat(datasets, dim='time')

# Export the combined dataset to a new NetCDF file
combined_ds.to_netcdf('apolis.nc')

print("Combining of NetCDF files is complete.")
	
	
