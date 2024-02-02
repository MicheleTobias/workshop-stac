## ----------------------------------------------------------------------------------------------
# Install Packages - only need to do this once
install.packages(c("rstac", "terra", "RColorBrewer", "getPass", "earthdatalogin"))


## ----------------------------------------------------------------------------------------------
# Load Libraries
library(rstac)          # interact with stac catalogs
library(terra)          # work with raster data
library(RColorBrewer)   # color pallets from Color Brewer, a library of colors designed for optimized readability in cartograhy
library(getPass)        # allows us to give the code our password without it printing to the console
library(earthdatalogin) # lets us authenticate to access NASA data


## ----------------------------------------------------------------------------------------------
# GDAL optimization for working with cloud-optimized data
setGDALconfig("GDAL_DISABLE_READDIR_ON_OPEN", "EMPTY_DIR")
setGDALconfig("CPL_VSIL_CURL_ALLOWED_EXTENSIONS", "TIF") 


## ----------------------------------------------------------------------------------------------
earthdata_username <- getPass("Earthdata User:")
earthdata_password <- getPass("Earthdata Password:")

# note: adding forcemask=FALSE would let you see the values as you type. We intentionally hid that for security of the presentation.


## ----------------------------------------------------------------------------------------------
earthdatalogin::edl_netrc(username = earthdata_username, password = earthdata_password)


## ----------------------------------------------------------------------------------------------
# connect to the stac endpoint we want to query
nasa_stac <- stac("https://cmr.earthdata.nasa.gov/stac/LPCLOUD")


## ----------------------------------------------------------------------------------------------
# We need bbox defined for STAC queries
# minimum longitude, minimum latitude, maximum longitude, and maximum latitude ---> 10 Mile Dunes
bbox = c( -123.824405, 39.485343, -123.748531, 39.556319)
# Later we'll need the same bbox as a Terra extent object for reading data
extent = ext(c(bbox[1],bbox[3],bbox[2],bbox[4]))

plot(extent, col="lightblue") #ok, this is perhaps not that interesting, but sometimes it's nice to have proof you did something correctly by plotting it


## ----------------------------------------------------------------------------------------------
search_hls <- stac_search(
  q = nasa_stac, # The STAC API connection we made earlier
  collections = "HLSS30.v2.0", # https://lpdaac.usgs.gov/products/hlss30v002/
  bbox = bbox, #bounding box that we made eariler
  datetime = "2023-06-01T00:00:00Z/2023-07-30T00:00:00Z",  # A closed interval: e.g. "2018-02-12T00:00:00Z/2018-03-18T12:31:12Z" 
  limit = 100 #limits how many results we see
)


## ----------------------------------------------------------------------------------------------
results_hls <- post_request(search_hls)

results_hls


## ----------------------------------------------------------------------------------------------
results_hls$features[[1]]


## ----------------------------------------------------------------------------------------------
results_hls$features[[1]]$properties


## ----------------------------------------------------------------------------------------------
results_hls$features[[1]]$properties$`eo:cloud_cover`


## ----------------------------------------------------------------------------------------------
results_hls <- items_filter(results_hls, properties$`eo:cloud_cover` < 10)

results_hls


## ----------------------------------------------------------------------------------------------
items <- assets_select(results_hls,
                       asset_names = c(
                         "B03", #green: 530 – 590 nm 
                         "B04", #red: 640 – 670 nm
                         "B8A" #Near-IR narrow: 850 – 880 nm
                         
                      ))


## ----------------------------------------------------------------------------------------------
urls<-assets_url(items)

urls


## ----------------------------------------------------------------------------------------------
urls<-assets_url(items$features[[1]])

urls


## ----------------------------------------------------------------------------------------------
band_green <- rast(urls[1], vsi=TRUE) 


## ----------------------------------------------------------------------------------------------
# reproject the extent to the HLS scene CRS.
utm_extent <- terra::project(extent, "epsg:4326", crs(band_green))
# Read the data from the URL for the selected extent
band_green_crop <- crop(band_green, utm_extent)


## ----------------------------------------------------------------------------------------------
band_red <- rast(urls[2], vsi=TRUE, win=utm_extent)
band_ir <- rast(urls[3], vsi=TRUE, win=utm_extent)


## ----------------------------------------------------------------------------------------------
normdiff <- function(x, y) {
  (x - y) / (x + y)
}


## ----------------------------------------------------------------------------------------------
ndwi = normdiff(band_green_crop, band_ir) 
ndvi = normdiff(band_ir, band_red)


## ----------------------------------------------------------------------------------------------
hist(ndwi, breaks = 40)


## ----------------------------------------------------------------------------------------------
summary(ndwi) #<-- ok, so there's some weirdness here


## ----------------------------------------------------------------------------------------------
hist(band_green_crop, breaks = 40)


## ----------------------------------------------------------------------------------------------
hist(ndvi, breaks = 40)


## ----------------------------------------------------------------------------------------------
summary(ndvi)


## ----------------------------------------------------------------------------------------------
layout(matrix(c(1,1,1,1,2,3), ncol=2, nrow=3, byrow=TRUE))
# 1
plot(ndwi, main="NDWI", range=c(-1,1), col=brewer.pal(name='Blues', n=9)) # the range parameter limits the plot to just values in the interval you give - good to filtering out outliers (which happen especially over the ocean)
# 2
plot(band_green_crop, main = "Green", col=brewer.pal(name='Greens', n=9))
# 3
plot(band_ir, main = "IR", col=brewer.pal(name='YlOrRd', n=9))


## ----------------------------------------------------------------------------------------------
# Plot NDVI
layout(matrix(c(1,1,1,1,2,3), ncol=2, nrow=3, byrow=TRUE))

# 1
plot(ndvi, main="NDVI", range=c(-1,1), col=brewer.pal(name='Greens', n=9))
# 2
plot(band_red, main = "Red", col=brewer.pal(name='YlOrRd', n=9))
# 3
plot(band_ir, main = "IR", col=brewer.pal(name='YlOrRd', n=9))


