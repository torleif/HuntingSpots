# New Zealand Hunting Spots
https://pages.cloudflare.com/


This project is a static re-creation of the defunct Hunting Spots website, which you can find at the following link: [Hunting Spots Showcase.](https://www.data.govt.nz/catalogue-guide/showcase/huntingspots/)
# How to Run Locally

To run this app on your computer, follow these steps:

1.    Install npm/node on your computer if you haven't already.
2.    Download this project and navigate to the downloaded folder in your terminal or command prompt.
3.    Install the necessary dependencies by running the command: `npm i`
4.    Start the local development server by running: `npm run dev`

# Building Topo50 XYZ Tile Folder with QGIS

The main Topo50 data from LINZ needs to be cut up into tile data, but this process can be time-consuming. Here's how to do it using QGIS:

1.    Download QGIS from their official website.
2.    Obtain the GeoTiFF files from [www.linz.govt.nz.](www.linz.govt.nz)
3.    Import the GeoTiff files into QGIS.
4.    Open the processing toolbox in QGIS.
5.    Select "Raster tools" > "Generate XYZ tiles" from the toolbox menu.
6.    Configure the settings: Min zoom: 1, Max zoom: 15, DPI: 300, Format: PNG, Width/Height: 512.
7.    For large datasets, export the tiles in smaller chunks to avoid issues.
8.    Repeat steps 6 and 7 until all the tile files have been created.

# Distribution of Animals from DOC

The Department of Conservation (DOC) maintains datasets on the distribution of animals across New Zealand, usually hosted on ARC GIS. You can search for and download these datasets from the following link: [DOC Animal Distribution Datasets.](https://doc-deptconservation.opendata.arcgis.com/datasets/4ca2ff58c4ac45ba984791edb6d952bf/explore?location=-42.430295%2C173.386366%2C9.44
)

# Simplifying Vector Maps

Some of the animal distribution maps can be very large files (over 20MB). To reduce their size, we can use QGIS to simplify them. Follow these steps:

1.    Load the GeoJSON file in QGIS.
2.    Go to the processing toolbox and select "Vector Geometry" > "Simplify."
3.    Choose the layer, the distance simplification method, and save the simplified file.
4.    Experiment with the tolerance value until you get a file size that works well. A tolerance value of 0.001 usually results in reasonable file sizes (around 20MB).