# GOAL: explore options for downloading and processing landsat or HLS data for California coastal dune systems

# Citations:
# rstac Example: https://brazil-data-cube.github.io/rstac/
# rstac Documentation: https://brazil-data-cube.github.io/rstac/reference/index.html 



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
search_landsat <- stac_search(
  q = landsat_stac,
  collections = "landsat-c2l2-sr",
  ids = NULL,
  bbox = c( -123.824405, 39.485343, -123.748531, 39.556319),  # minimum longitude, minimum latitude, maximum longitude, and maximum latitude --- 
  datetime = "2023-06-01T00:00:00Z/2023-06-30T00:00:00Z",  # A closed interval: "2018-02-12T00:00:00Z/2018-03-18T12:31:12Z" 
  intersects = NULL,
  limit = 100
)

# run the search
results_landsat <- get_request(search_landsat)

# see what the results are from our search
results_landsat




# SEARCH HLS ----------------------------------------------------------

# connect to the HLS stac catalog endpoint
#hls_stac <- stac("") 






#dune_bbox<-