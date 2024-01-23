#GOAL: configure gdal to download data from a STAC with the terra package


# Citation: https://stackoverflow.com/questions/71605910/how-do-i-use-the-terra-r-package-with-cloud-optimized-geotiffs-requiring-authent 

library(terra) 
setGDALconfig("GDAL_HTTP_UNSAFESSL", "YES")
setGDALconfig("GDAL_HTTP_COOKIEFILE", ".rcookies") 
setGDALconfig("GDAL_DISABLE_READDIR_ON_OPEN", "EMPTY_DIR")
setGDALconfig("CPL_VSIL_CURL_ALLOWED_EXTENSIONS", "TIF") 


# example of downloading from a STAC URL:

# url <- "/vsicurl/https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/HLSS30.020/HLS.S30.T10SEJ.2021214T184919.v2.0/HLS.S30.T10SEJ.2021214T184919.v2.0.B8A.tif" 

# r <- rast(url)