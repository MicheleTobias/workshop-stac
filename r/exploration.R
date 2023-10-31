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




# SEARCH LANDSAT ----------------------------------------------------------


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




# SEARCH HLS ----------------------------------------------------------

# connect to the HLS stac catalog endpoint
#hls_stac <- stac("") 






#dune_bbox<-