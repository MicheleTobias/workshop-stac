#GOAL: configure rgdal to dowload data from a STAC with the terra package


# Citation: https://stackoverflow.com/questions/71605910/how-do-i-use-the-terra-r-package-with-cloud-optimized-geotiffs-requiring-authent 

library(terra) 
setGDALconfig("GDAL_HTTP_UNSAFESSL", "YES")
setGDALconfig("GDAL_HTTP_COOKIEFILE", ".rcookies") 
setGDALconfig("GDAL_DISABLE_READDIR_ON_OPEN", "EMPTY_DIR")
setGDALconfig("CPL_VSIL_CURL_ALLOWED_EXTENSIONS", "TIF") 