# GOAL: explore options for downloading and processing landsat or HLS data for California coastal dune systems

# Citations:
# rstac Example: https://brazil-data-cube.github.io/rstac/
# rstac Documentation: https://brazil-data-cube.github.io/rstac/reference/index.html 
# r-spatial STAC: https://r-spatial.org/r/2021/04/23/cloud-based-cubes.html
# stac spec tutorial on querying: https://stacspec.org/en/tutorials/2-using-rstac-and-cql2-to-query-stac-api/
# stac spec tutorial on downloading data: https://stacspec.org/en/tutorials/1-download-data-using-r/



# SET UP -------------------------------------------------------------------

# load libraries

#install.packages("rstac")

library(rstac) # rstac is a client for finding and downloading data stored in a SpatioTemporal Asset Catalog (rstac) and available trough an API




# SEARCH LANDSAT ----------------------------------------------------------


# connect to the lansat stac catalog endpoint
landsat_stac <- stac("https://landsatlook.usgs.gov/stac-server")

get_request(landsat_stac)

landsat_collections <- get_request(collections(landsat_stac))


#set up the search parameters
#   Info on Landsat collections: https://stacindex.org/catalogs/usgs-landsat-collection-2-api#/
search_landsat <- stac_search(
  q = landsat_stac,
  collections = "landsat-c2l2-sr",
  ids = NULL,
  bbox = c( -123.824405, 39.485343, -123.748531, 39.556319),  # minimum longitude, minimum latitude, maximum longitude, and maximum latitude --- 
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




# ANALYSIS LANDSAT ----------------------------------------------------------------

# select assets from the list of options returned
items <- assets_select(results_landsat,
                       asset_names = c("B02", "B03", "SR_B1", "SR_B2"))

# download a scene




# SEARCH HLS ----------------------------------------------------------

# connect to the HLS stac catalog endpoint
#hls_stac <- stac("") 






#dune_bbox<-