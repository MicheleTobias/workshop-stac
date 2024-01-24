# Downloading Satellite Data from SpatioTemporal Asset Catalogs (STAC)

Authors: 

* Michele Tobias, PhD - [University of California Davis DataLab](https://datalab.ucdavis.edu/)
* Alex Mandel, PhD - [Development Seed](https://developmentseed.org/)

last update: 2024-01-24



## Introduction

Spatiotemporal asset catalogs (STAC) are growing in popularity as a way to make data available in a standardized way, but getting started with these tools is not always straight forward or clear to people who did not set them up. In this workshop, we hope to demystify working with STAC catalogs. Learn how to connect to, search, and download data from a STAC in R.

By the end of the workshop, participants will be familiar with STAC terminology, be able to connect to a STAC, and search and downlaod STAC data.

You may already be familiar with online catalogs like [USGS EarthExplorer](https://earthexplorer.usgs.gov/) for exploring and downloading aerial imagery. Many of these website-based catalogs are difficult to use, especially if you need to download a lot of data, but they work once you get used to them. So why take the time to learn how to access STAC catalogs through code? 

Using a catalog lets you: 
- update or modify your query and easily run it again
- filter based on metadata - you can access all of the metadata, not just what the web designer decided to include
- increase the reproducability (see also [FAIR](https://www.go-fair.org/fair-principles/)) of your project because the code documents what you did
- Reduce the amount of data you need to download, manage, and store. You can always download the data again so you can delegate the storage to the organization that produced the data.
- (we won't cover this today but...) move your computation closer to the data. (e.g if the data is on AWS you could run your compute on AWS) - i.e. keep your code and the data together in the cloud


## SpatioTemporal Asset Catalogs (STAC)

### What is it?

SpatioTemporal Asset Catalogs (STAC) provide a standard way of describing geospatial data in a computer-oriented, but still human readable, format (JSON). It was originally created to catalog large amounts of Satellite based Earth Observation data.

### Why is it useful?
We use STAC to organize a large number of files. This organization method makes it possible to search for the files  needed for a given analysis and then pass the results to the analysis tools. STAC describes what to expect inside a file and where to find the file in a way that can be passed to computer code or programs that need to access the data. STAC is a way to organize data that makes it easy for both people and computers to find and use data.

STAC is organized through a series of hierarchical entities. Let's look at some of these entities:

* Asset - a single file, such as a single band of a satellite image
* Item - one or more Assets that contain data about the same place in time such as a satellite image with multiple bands.
* Collection - one or more Items that have shared characteristics (e.g. same Sensor, processing level, or product)
* Catalog - one or more Collections (e.g. Landsat7 and Landsat8 collections are both in the USGS catalog)
* STAC API - a web url for searching a STAC Catalog using computer software or code.  (API = Application Programming Interface)

Learn more: https://stacspec.org/en/tutorials/intro-to-stac/

### Cloud Optimized GeoTIFF (COG)

Cloud Optimized GeoTIFF (COG) is a common file format stored in a STAC catalog. The GeoTiff format adds spatial reference metadata to the TIFF image format allowing you to store regularly gridded data, aka raster data, that is referenced to the earth. This lets you load data in geospatial software and know where in the world the data is and how much ground each pixel represents. 

What does "Cloud Optimized" mean? Why is this helpful?

The data inside the file is organized to allow easier and faster access to portions, or chunks, of data. This allows you to only read the part of data you need instead of the whole file. This is great news for people with small study areas or study areas that cross multiple satellite scenes!

Even more information: [Cloud-Optimized Geospatial Formats Guide](https://guide.cloudnativegeo.org/) 




### Interacting with a STAC Catalog Through an API

An Application Programming Interface (API) is a set of commands that a service knows how to respond to. You can think of it just like Library of Functions in programming. Each Function takes some set of required and optional arguments and then returns results. Web APIs typically follow a similar structure: they have a base URL (the website you connect to) followed by arguments (or parameters) that tell the website what information you want to know. Arguments might indicate which endpoint (think of this as a table or databases of data) you want to search, maybe a date range, or how much cloud cover is acceptable. Each API endpoint will have specific information you can ask for. You might think of it like a table with columns.

```
**You Already Use APIs!**

You already use an API. Every time you search with Google (or any search engine for that matter), you're using a web interface to build an API query. If you type "STAC Catalog" into Google, it will build the following URL (with some extra stuff at the end that isn't required):

https://www.google.com/search?q=STAC+Catalog

- Base URL = google.com
- Endpoint = search
- Start of the parameters = ?
- Search Parameters = q (short for "query")
- String to search for = STAC+Catalog (+ represents the space we would type in the search box and also indicates an "and" query [as opposed to an "or" query])
```

Let's look at some examples from the Microsoft Planetary Computer. You can open the links below in a web browser. The response will be text in GeoJSON format. It's note necessarily very easy to read, but you can if you want.

List collections in the Catalog by connecting to the collections endpoint: https://planetarycomputer.microsoft.com/api/stac/v1/collections

- Base URL: https://planetarycomputer.microsoft.com/api/stac/v1/
- API Endpoint: collections


List items in the specified Collection: https://planetarycomputer.microsoft.com/api/stac/v1/collections/3dep-lidar-dsm/items

- API Endpoint: collections
- Arguments:  3dep-lidar-dsm, items

This asks for items that are part of `3dep-lidar-dsm`, if we left off the items parameter, it would return information about the collection.

Search for a specific geographic area: https://planetarycomputer.microsoft.com/api/stac/v1/search?collections=3dep-lidar-dsm&bbox=-124.41060660766607,32.5342307609976,-114.13445790587905,42.00965914828148&limit=25

- API Endpoint: search
- Arguments/Parameters: collections, bbox, limit


We've been looking at API examples that work in our web browser to get an idea of how APIs work. But we'll be working in R. You'll see when we start coding that often R packages that work with APIs will translate the parameters to function arguments and in the underlying code, they will build the URL to send to the API. In R, this might look like:

```
search(collections=..., bbox=..., limit=...)
```

**Resources**

- A list of some publicly accessible STAC Catalogs with APIs https://stacindex.org/catalogs?type=api
- A list of software and programming libraries for using STAC https://stacindex.org/ecosystem?category=Client
- An example of STAC API documentation that documents how to use the API. https://planetarycomputer.microsoft.com/api/stac/v1/docs

## A Typical Workflow:

1. First time only: Configure your environment & do your set up for authentication - ( i.e. sign up for an account with the Data Provider )

1. Authenticate (log in to your account using R or Python code)

1. Search the STAC catalog (using the API) to see what's available

1. Decide which images you want

1. Retrieve the data you want to work with

1. Run your analysis



## Links to example code

Now let's try some of the concepts we've learned in R! The [Workshop_Notebook.qmd](r/Workshop_Notebook.qmd) file is an R Quarto notebook that you can open in R Studio. It will walk us through downloading some Landsat data from the NASA's EarthData STAC Catalog for 10 Mile Dunes in northern California to run an exploratory analysis.



# Reference Material & Further Reading

[Cloud-based processing of satellite image collections in R using STAC, COGs, and on-demand data cubes](https://r-spatial.org/r/2021/04/23/cloud-based-cubes.html)

[Cloud-Optimized Geospatial Formats Guide](https://guide.cloudnativegeo.org/)
