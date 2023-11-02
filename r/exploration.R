# GOAL: explore options for downloading and processing landsat or HLS data for California coastal dune systems

# Citations:
# rstac Example: https://brazil-data-cube.github.io/rstac/
# rstac Documentation: https://brazil-data-cube.github.io/rstac/reference/index.html 
# r-spatial STAC: https://r-spatial.org/r/2021/04/23/cloud-based-cubes.html
# stac spec tutorial on querying: https://stacspec.org/en/tutorials/2-using-rstac-and-cql2-to-query-stac-api/
# stac spec tutorial on downloading data: https://stacspec.org/en/tutorials/1-download-data-using-r/
# https://lpdaac.usgs.gov/resources/e-learning/getting-started-with-cloud-native-harmonized-landsat-sentinel-2-hls-data-in-r/ 



# SET UP -------------------------------------------------------------------

# get access to the data:
#   1. Sign up for an Earthdata Login account: https://urs.earthdata.nasa.gov/
#   2. NASA uses a NetRC File to provide authentication information (username and password) when you download data:
#       A. Write your NetRC file using this script from NASA: https://git.earthdata.nasa.gov/projects/LPDUR/repos/hls_tutorial_r/browse/Scripts/earthdata_netrc_setup.R It writes a text file with your user name and password to your user home directory
#       B. Configure rgdal: https://stackoverflow.com/questions/71605910/how-do-i-use-the-terra-r-package-with-cloud-optimized-geotiffs-requiring-authent  


# load libraries

#install.packages("rstac")

# rstac is a client for finding and downloading data stored in a SpatioTemporal Asset Catalog (rstac) and available trough an API
library(rstac) 
library(terra)
library(httr)
library(RColorBrewer)

# configuration for GDAL to work with the NetRC file
setGDALconfig("GDAL_HTTP_UNSAFESSL", "YES")
setGDALconfig("GDAL_HTTP_COOKIEFILE", ".rcookies") 
setGDALconfig("GDAL_DISABLE_READDIR_ON_OPEN", "EMPTY_DIR")
setGDALconfig("CPL_VSIL_CURL_ALLOWED_EXTENSIONS", "TIF") 



# AUTHENTICATE NASA EARTHDATA ----------------------------------------------------

edl_set_token <- function (username = Sys.getenv("EARTHDATA_USER"), 
                           password = Sys.getenv("EARTHDATA_PASSWORD"),
                           token_number = 1
) {
  base <- 'https://urs.earthdata.nasa.gov'
  list_tokens <- "/api/users/tokens"
  pw <- openssl::base64_encode(paste0(username, ":", password))
  resp <- httr::GET(paste0(base,list_tokens),
                    httr::add_headers(Authorization= paste("Basic", pw)))
  p <- httr::content(resp, "parsed")[[token_number]]
  
  if(is.null(p$access_token)) {
    request_token <- "/api/users/token"
    resp <- httr::GET(paste0(base,request_token),
                      httr::add_headers(Authorization= paste("Basic", pw)))
    p <- httr::content(resp, "parsed")
  }
  header = paste("Authorization: Bearer", p$access_token)
  Sys.setenv("GDAL_HTTP_HEADERS"=header)
  invisible(header)
}

earthdata_username <- readline("Earthdata Username:")
earthdata_password <- readline("Earthdata Password:")

edl_set_token(username = earthdata_username, password = earthdata_password)


# SEARCH HLS ----------------------------------------------------------

## https://lpdaac.usgs.gov/resources/e-learning/getting-started-with-cloud-native-harmonized-landsat-sentinel-2-hls-data-in-r/

# connect to the landsat stac catalog endpoint
nasa_stac <- stac("https://cmr.earthdata.nasa.gov/stac/LPCLOUD")


bbox = c( -123.824405, 39.485343, -123.748531, 39.556319)
extent = ext(c(bbox[1],bbox[3],bbox[2],bbox[4]))

#set up the search parameters
search_hls <- stac_search(
  q = nasa_stac,
  #collections = "landsat-c2l2-sr", #	Landsat Collection 2 Level-2 UTM Surface Reflectance (SR) Product
  collections = "HLSS30.v2.0", # https://hls.gsfc.nasa.gov/products-description/s30/
  ids = NULL,
  bbox = bbox,  # minimum longitude, minimum latitude, maximum longitude, and maximum latitude ---> 10 Mile Dunes
  datetime = "2023-06-01T00:00:00Z/2023-07-30T00:00:00Z",  # A closed interval: "2018-02-12T00:00:00Z/2018-03-18T12:31:12Z" 
  intersects = NULL,
  limit = 100
)

# run the search, NASA needs a post not get for some reason
results_hls <- post_request(search_hls)

# see what the results are from our search
results_hls

# inspect the first element of the results
results_hls$features[[1]]

# You can see where the cloud cover is in the STAC record to filter
results_hls$features[[1]]$properties$`eo:cloud_cover`


# what assets are available for a given item?
names(results_hls$features[[1]]$assets)
# https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/harmonized-landsat-sentinel-2-hls-overview/#hls-naming-conventions




# ANALYSIS HLS ----------------------------------------------------------------

# Items have assets - example: item = photo, asset = a specific band
items <- assets_select(results_hls,
                       asset_names = c(
                         "B03", #green: 0.53 – 0.59
                         "B8A", #NIR narrow: 0.85 – 0.88
                         "B04"  #red: 0.64 – 0.67
                         ))

# get the URLs for the assets
urls<-assets_url(items)

# setup Rasters as part of a scene
# The data is read until you try to calculate or plot values

band_green <- rast(paste0('/vsicurl/', urls[1])) 
utm_extent <- terra::project(extent, "epsg:4326", crs(band_green))
band_green_crop <- crop(band_green, utm_extent)
#you want to pass the an spatExtent to limit the data downloaded
#invalid extent because the HLS scene is in UTM
# TODO: reproject extent to UTM
#band_green <- rast(paste0('/vsicurl/',urls[1]), win=extent, snap="in") 

band_ir <- rast(paste0('/vsicurl/', urls[25]), win=utm_extent)
band_red <- rast(paste0('/vsicurl/', urls[13]), win=utm_extent)

# calculate NDWI = (Green – NIR)/(Green + NIR)

normdiff <- function(x, y) {
  (x - y) / (x + y)
}

ndwi = normdiff(band_green_crop, band_ir) 
ndvi = normdiff(band_ir, band_red)

hist(ndwi, breaks = 40)
summary(ndwi) #<-- ok, so there's some weirdness here
hist(band_green_crop, breaks = 40)

hist(ndvi, breaks = 40)
summary(ndvi)


plot(band_green_crop)
plot(band_ir)
plot(ndwi, main="NDWI", range=c(-1,1)) # the range parameter limits the plot to just values in the interval you give - good to filtering out outliers (which happen especially over the ocean)

# Combine plots and apply color palettes 

# Plot NDWI

# Make a layout with one big figure at the top and two smaller figures below. The first figure takes up 4 cells in the matrix.
layout(matrix(c(1,1,1,1,2,3), ncol=2, nrow=3, byrow=TRUE))

# 1
plot(ndwi, main="NDWI", range=c(-1,1), col=brewer.pal(name='Blues', n=9))
# 2
plot(band_green_crop, main = "Green", col=brewer.pal(name='Greens', n=9))
# 3
plot(band_ir, main = "IR", col=brewer.pal(name='YlOrRd', n=9))


# Plot NDVI
layout(matrix(c(1,1,1,1,2,3), ncol=2, nrow=3, byrow=TRUE))

# 1
plot(ndvi, main="NDVI", range=c(-1,1), col=brewer.pal(name='Greens', n=9))
# 2
plot(band_red, main = "Red", col=brewer.pal(name='YlOrRd', n=9))
# 3
plot(band_ir, main = "IR", col=brewer.pal(name='YlOrRd', n=9))






# ***** IN PROGRESS *****

# SEARCH LANDSAT LOOK ----------------------------------------------------------


# connect to the landsat stac catalog endpoint
landsat_stac <- stac("https://landsatlook.usgs.gov/stac-server")

# test it out
get_request(landsat_stac)

# what collections are available?
#   Info on Landsat collections: https://stacindex.org/catalogs/usgs-landsat-collection-2-api#/ 
landsat_collections <- get_request(collections(landsat_stac))
landsat_collections


#set up the search parameters
search_landsat <- stac_search(
  q = landsat_stac,
  collections = "landsat-c2l2-sr", #	Landsat Collection 2 Level-2 UTM Surface Reflectance (SR) Product
  ids = NULL,
  bbox = c( -123.824405, 39.485343, -123.748531, 39.556319),  # minimum longitude, minimum latitude, maximum longitude, and maximum latitude ---> 10 Mile Dunes
  datetime = "2023-06-01T00:00:00Z/2023-07-30T00:00:00Z",  # A closed interval: "2018-02-12T00:00:00Z/2018-03-18T12:31:12Z" 
  intersects = NULL,
  limit = 100
)

# run the search
results_landsat <- get_request(search_landsat)

# see what the results are from our search
results_landsat

# inspect the first element of the results
results_landsat$features[[1]]


# FILTER RESULTS ----------------------------------------------------------

# We can filter the results of our search further by adding 
# a query to our search parameters

# filter by cloud cover
#   ext_query adds additional parameters to the search using item properties
results_landsat_cloudcover <- 
  post_request(
    ext_query(search_landsat, 'eo:cloud_cover' < 10) 
  )

# see the results
results_landsat_cloudcover

# see the list of items available from our search
results_landsat_cloudcover$features

# what assets are available for a given item?
names(results_landsat_cloudcover$features[[1]]$assets)


# ANALYSIS LANDSAT ----------------------------------------------------------------

# Items have assets - example: item = photo, asset = a specific band
items <- assets_select(results_landsat_cloudcover,
                       asset_names = c("green", "nir08"))

# get the URLs for the assets
urls<-assets_url(items)

# download a scene

band_green <- rast(urls[1])

band_ir <- rast(urls[2])

# calculate NDWI = (Green – NIR)/(Green + NIR)
