# Downloading Satellite Data from SpatioTemporal Asset Catalogs (STAC)

Authors: 

* Michele Tobias, PhD - [University of California Davis DataLab](https://datalab.ucdavis.edu/)
* Alex Mandel, PhD - [Development Seed](https://developmentseed.org/)

last update: 2023-12-05



## Introduction

What are we generally trying to learn?

Why does it matter? Why do it this way vs. downloading images and storing them yourself?



## SpatioTemporal Asset Catalogs (STAC)

### What is it?

A standard way of describing geospatial data in a computer first but still human readable format (JSON). It was originally created to catalog large amounts of Satellite based Earth Observation data.

### Why is it useful?
We use STAC to organize a large number of files and make it possible to search for which files are needed for a given analysis and then pass the results to the analysis tools. The key is that STAC describes what to expect inside a file and where to find the file in a way that can be passed to computer code or programs that need to access the data.

Define: 

* Asset - a single file
* Item - one or more Assets that contain data about the same place in time (e.g. multiple bands from the same capture) - aka Scenes. 
* Collection - one or more Items that have shared characteristics (e.g. same Sensor, processing level, or product)
* Catalog - one or more Collections (e.g. Landsat7 and Landsat8)
* STAC API - a web interface for searching a STAC Catalog using computer software or code. API = Application Programming Interface

https://stacspec.org/en/tutorials/intro-to-stac/

### Cloud Optimized GeoTIFF (COG)

What is a GeoTIFF? Why do you want to work with this?

What does "Cloud Optimized" mean? Why is this helpful?

This is helpful: [Cloud-Optimized Geospatial Formats Guide](https://guide.cloudnativegeo.org/) - probably because one of the authors looks very familiar!


### More detail about APIs in general and STAC API specifically


## A Typical Workflow:

1. First time only: Configure your environment & do your set up for authentication - i.e. sign up for an account and create the NetRC file

1. Authenticate (log in to your account using R or Python code)

1. Search the STAC catalog (using the API) to see what's available

1. Decide which images you want

1. Retrieve the data you want to work with

1. Run your analysis



## Links to example code














# Reference Material & Further Reading

[Cloud-based processing of satellite image collections in R using STAC, COGs, and on-demand data cubes](https://r-spatial.org/r/2021/04/23/cloud-based-cubes.html)

[Cloud-Optimized Geospatial Formats Guide](https://guide.cloudnativegeo.org/)