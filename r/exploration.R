# GOAL: explore options for downloading and processing landsat or HLS data for California coastal dune systems

# Citations:
# https://brazil-data-cube.github.io/rstac/



# SET UP -------------------------------------------------------------------

# load libraries

#install.packages("rstac")

library(rstac) # rstac is a client for finding and downloading data stored in a SpatioTemporal Asset Catalog (rstac) and available trough an API


# connect to the lansat stac catalog endpoint
landsat_stac <- stac("https://landsatlook.usgs.gov/stac-server")

get_request(landsat_stac)

landsat_collections <- get_request(collections(landsat_stac))



search_landsat <- stac_search(
  q = landsat_stac,
  collections = "landsat-c2l2-sr",
  ids = NULL,
  bbox = c( -123.824405, 39.485343, -123.748531, 39.556319),  # likely: minimum longitude, minimum latitude, maximum longitude, and maximum latitude --- NW: 39.562010, -123.823032  SE: 39.486138, -123.734455
  datetime = "2023-06-01T00:00:00Z/2023-06-30T00:00:00Z",  # A closed interval: "2018-02-12T00:00:00Z/2018-03-18T12:31:12Z" 
  intersects = NULL,
  limit = 100
)

get_request(search_landsat)

# connect to the HLS stac catalog endpoint
#hls_stac <- stac("") 






#dune_bbox<-