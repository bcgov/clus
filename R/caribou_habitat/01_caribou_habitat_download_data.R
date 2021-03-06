# Copyright 2018 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

#=================================
#  Script Name: 01_download_data.R
#  Script Version: 1.0
#  Script Purpose: Download data for provincial caribou habitat model analysis.
#  Script Author: Tyler Muhly, Natural Resource Modeling Specialist, Forest Analysis and 
#                 Inventory Branch, B.C. Ministry of Forests, Lands, and Natural Resource Operations.
#                 Report is located here: 
#  Script Date: 25 July 2018
#  R Version: 3.4.3
#  R Package Versions: 
#  Data: 
#=================================
require (downloader)
require (dplyr)
require (sf)
require (lubridate)
require (RPostgreSQL)
require (raster)
require (rpostgis)
# data directory
setwd ('C:\\Work\\caribou\\clus_data\\')

#########################
# MANUAL DATA DOWNLOADS #
#########################
# copied from BCGW into geodatabase; for uploading to postgres

# caribou range boundaries; downloaded 25 July 2018
# <https://catalogue.data.gov.bc.ca/dataset/caribou-herd-locations-for-bc>
# Name in GDB: boundary_caribou_pop_20180725

# BEC Map; downloaded 25 July 2018
# <https://catalogue.data.gov.bc.ca/dataset/biogeoclimatic-ecosystem-classification-bec-map>
# Name in GDB: bec_poly_20180725

# Cutblock data; downloaded 25 July 2018
# <https://catalogue.data.gov.bc.ca/dataset/harvested-areas-of-bc-consolidated-cutblocks->
# Name in GDB: cutblocks_20180725

# VRI Public; downloaded 25 July 2018
# <https://catalogue.data.gov.bc.ca/dataset/vri-forest-vegetation-composite-polygons-and-rank-1-layer>
# Name in GDB: vir_public_20180725

# VRI Internal; downloaded 25 July 2018
# NOTE: the internal data provides access to VRI in TFLs, which is NOT available in the public version 
# <\\spatialfiles2.bcgov\work\FOR\VIC\HTS\DAM\WorkArea\Mcdougall\Projects\2018\PROJECTION_2018\Data\INTERNAL_VEG_COMP\INTERNAL_VEGCOMP
# Name in GDB: vri_internal_20180725

# Fire; downloaded 25 July 2018
# <https://catalogue.data.gov.bc.ca/dataset/fire-perimeters-historical>
# Name in GDB: fire_historic_20180725

# Oil and gas well/facility; downloaded 25 July 2018
# After 2016: <https://catalogue.data.gov.bc.ca/dataset/oil-and-gas-commission-facility-location-permits>
# Name in GDB: oil_gas_facility_post2016_20180725
# Before 2016: <https://catalogue.data.gov.bc.ca/dataset/oil-and-gas-commission-pre-2016-facility-locations>
# Name in GDB: oil_gas_facility_pre2016_20180725
# Historic <https://catalogue.data.gov.bc.ca/dataset/trim-cultural-points>
# Name in GDB: trim_points_20180815
# Well surface holes:  <https://catalogue.data.gov.bc.ca/dataset/well-surface-hole-status>
# Name in GDB: well_surface_hole_20180815

# Trasnmission Lines; downloaded 25 July 2018
# <https://catalogue.data.gov.bc.ca/dataset/bc-transmission-lines>
# Name in GDB: transmission_line_20180725

# Railways; downloaded 25 July 2018
# <https://catalogue.data.gov.bc.ca/dataset/railway-track-line>
# Name in GDB: railway_20180725

# Major Projects, for wind and mines; downloaded 25 July 2018
# <https://catalogue.data.gov.bc.ca/dataset/natural-resource-sector-major-projects-points>
# Name in GDB: major_projects_20180725

# Integrated roads data from cumulative effects; copied June 18, 2018
# \\spatialfiles.bcgov\\work\\srm\\bcce\\shared\\data_library\roads\2017\BC_CE_IntegratedRoads_2017_v1_20170214.gdb
# Get RASTER from Kyle

# Ski Resorts
# https://catalogue.data.gov.bc.ca/dataset/ski-resorts
# Name in GDB: ski_resorts_20180813

# Mines from MEMPR
# http://www.empr.gov.bc.ca/Mining/Geoscience/MapPlace/metadata/Pages/minf_metadata.aspx
# Name in GDB: minfile_20180813
# http://www.empr.gov.bc.ca/Mining/Geoscience/MINFILE/ProductsDownloads/MINFILEDocumentation/CodingManual/Pages/default.aspx

# Pipelines; downloaded 25 July 2018
# After 2006: <https://catalogue.data.gov.bc.ca/dataset/oil-and-gas-commission-pipeline-right-of-way-permits>
# Name in GDB: pipeline_post2006_20180725
# After 2016: <https://catalogue.data.gov.bc.ca/dataset/oil-and-gas-commission-pipeline-segment-permits>
# Name in GDB: pipeline_post2016_20180725
# https://catalogue.data.gov.bc.ca/dataset/tantalis-crown-tenures
# Name in GDB: tantalis_crown_tenures_20180814
# https://catalogue.data.gov.bc.ca/dataset/tantalis-surveyed-parcels
# Name in GDB: tantalis_surveyed_row_20180814
# https://catalogue.data.gov.bc.ca/dataset/trim-cultural-lines
# Name in GDB: trim_lines_20180814

# Powerplants/Clean Energy
# https://open.canada.ca/data/en/dataset/490db619-ab58-4a2a-a245-2376ce1840de
# Name in GDB: power_renewable_1mw_20180816
# https://open.canada.ca/data/en/dataset/40fbe40c-01cd-49d3-8add-0d20ed64c90d
# Name in GDB: powerplant_100mw_20180816

# Watercourses
# https://catalogue.data.gov.bc.ca/dataset/watercourses-trim-enhanced-base-map-ebm
# Name in GDB: watercourses_20180817

# Lakes
# https://catalogue.data.gov.bc.ca/dataset/waterbodies-trim-enhanced-base-map-ebm
# Name in GDB: lakes_20180817

# Wetlands
# Enhanced boreal wetland classification for boreal BC only
# this version was derived from a Ducks Unlimited dataset, reclassified for caribou habitat 
# report on how the classes were derived is here: https://www.researchgate.net/profile/Gilbert_Proulx/post/Are_there_studies_in_forest_ecology_and_conservation_that_used_the_Bayesian_approach_to_research/attachment/59d6203379197b807797eab3/AS%3A289179285114880%401445957123491/download/2015-2Wilson_FINAL.pdf
# the data is downloadable from Hectares BC: https://hectaresbc.ca/app/habc/HaBC.html
# you need an account to access the data 
# click on the 'raster data' tab, click on the 'enhanced wetland classification' in the data layer window
# click the export raster data button (looks like a sheet of paper with an arrow) and you will be 
# prompted to enter your email and format you want; the data arrives via an email link
wetlands <- raster ("C:\\Work\\caribou\\clus_data\\wetland\\boreal\\Enhanced_Wetland_Classification\\wettype.ewcmosaic.tif")
wetlands <- projectRaster (wetlands, crs = "+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs")
connKyle <- dbConnect(drv = RPostgreSQL::PostgreSQL(), 
                      host = key_get('dbhost', keyring = 'postgreSQL'),
                      user = key_get('dbuser', keyring = 'postgreSQL'),
                      dbname = key_get('dbname', keyring = 'postgreSQL'),
                      password = key_get('dbpass', keyring = 'postgreSQL'),
                      port = "5432")
conn <- dbConnect (drv = RPostgreSQL::PostgreSQL(), 
                   host = "",
                   user = "postgres",
                   dbname = "postgres",
                   password = "postgres",
                   port = "5432")
pgWriteRast (conn, c ("vegetation", "wetlands_boreal_caribou"), wetlands, overwrite = TRUE)
pgWriteRast (connKyle, "wetlands_boreal_caribou", wetlands, overwrite = TRUE)
wetland.lut <- read.csv ("C:\\Work\\caribou\\clus_data\\wetland\\boreal\\Enhanced_Wetland_Classification\\metadata\\wettype_ewcmosaic_category_metadata.csv",
                         sep = ",")
dbWriteTable (conn = connKyle, 
              name = "lut_wetlands_boreal_caribou", 
              value = wetland.lut) 
dbWriteTable (conn = conn, 
              name = c ("vegetation", "lut_wetlands_boreal_caribou"), 
              value = wetland.lut) 
dbDisconnect (conn) # connKyle

############################
# Cumulative Effects Data #
##########################
# \\transverse\work\srm\bcce\shared\data_library\development\Consolidated_Development\2015\
# data not maintained or updated (or particularly well documented)
# produced in 2015
# some spot-checking suggests it is fairly accurate

# Mines
# Name in GDB: ce_mine_2015_20180814

# Seismic data
# NE_Seismic and Remainder_Seismic merged together
# Name in GDB: seismic_ce_2015

# Agriculture data
# Name in GDB: agriculture_ce_2015

###################################
# Data downloadable from websites #
###################################
# soil parent material (endurign feature)
# available from Hectares BC: https://www.hectaresbc.org/app/habc/HaBC.html

# bc boundary; downloaded 25 July 2018
# available from federal government via https://open.canada.ca/data/dataset/bab06e04-e6d0-41f1-a595-6cff4d71bedf
download ("http://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/gpr_000b11a_e.zip", 
          dest = "province\\border.zip", 
          mode = "wb")
unzip ("province\\border.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\caribou_habitat_model\\province")
file.remove ("province\\border.zip")

# current climate measures; downloaded 6 November 2018
# Reference: <http://climatebcdata.climatewna.com/#3._reference> # Wang, T., Hamann, A., Spittlehouse, D.L., Murdock, T., 2012. ClimateWNA - High-Resolution Spatial Climate Data for Western North America. Journal of Applied Meteorology and Climatology, 51: 16-29.
# Annual
download ("http://climatebcdata.climatewna.com/download/Normal_1981_2010MSY/Normal_1981_2010_annual.zip", 
          dest = "climate\\annual\\Normal_1981_2010_annual.zip", 
          mode = "wb")
unzip ("climate\\annual\\Normal_1981_2010_annual.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\climate\\annual")
file.remove ("climate\\annual\\Normal_1981_2010_annual.zip")

# Seasonal
download ("http://climatebcdata.climatewna.com/download/Normal_1981_2010MSY/Normal_1981_2010_seasonal.zip", 
          dest = "climate\\seasonal\\Normal_1981_2010_seasonal.zip", 
          mode = "wb")
unzip ("climate\\seasonal\\Normal_1981_2010_seasonal.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\climate\\seasonal")
file.remove ("climate\\seasonal\\Normal_1981_2010_seasonal.zip")

# Monthly
download ("http://climatebcdata.climatewna.com/download/Normal_1981_2010MSY/Normal_1981_2010_monthly.zip", 
          dest = "climate\\monthly\\Normal_1981_2010_monthly.zip", 
          mode = "wb")
unzip ("climate\\monthly\\Normal_1981_2010_monthly.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\climate\\monthly")
file.remove ("climate\\monthly\\Normal_1981_2010_monthly.zip")

# Monthly derived
download ("http://climatebcdata.climatewna.com/download/Normal_1981_2010MSY/Normal_1981_2010_MonthDrv.zip", 
          dest = "climate\\monthly\\Normal_1981_2010_MonthDrv.zip", 
          mode = "wb")
unzip ("climate\\monthly\\Normal_1981_2010_MonthDrv.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\climate\\monthly")
file.remove ("climate\\monthly\\Normal_1981_2010_MonthDrv.zip")

# Mountain Pine Beetle
# https://www2.gov.bc.ca/gov/content/industry/forestry/managing-our-forest-resources/forest-health/aerial-overview-surveys/methods/damage-ratings
download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2017/Final%20Dataset/FHF_2017.zip", 
            dest = "mountain_pine_beetle\\2017.zip", 
            mode = "wb")
unzip ("mountain_pine_beetle\\2017.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2017")
file.remove ("mountain_pine_beetle\\2017.zip")
  
download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2016/AOS_2016_Shapefiles_and_TSA_Spreadsheet_Jan25.zip",
          dest = "mountain_pine_beetle\\2016.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\2016.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2016")
file.remove ("mountain_pine_beetle\\2016.zip")

download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2015/final_prov_data/FHF_spatial_Feb11.zip",
          dest = "mountain_pine_beetle\\2015.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\2015.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2015")
file.remove ("mountain_pine_beetle\\2015.zip")

download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2014/2014_FHF_Jan23.zip",
          dest = "mountain_pine_beetle\\2014.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\2014.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2014")
file.remove ("mountain_pine_beetle\\2014.zip")

download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2013/FHF_2013_Jan24.zip",
          dest = "mountain_pine_beetle\\2013.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\2013.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2013")
file.remove ("mountain_pine_beetle\\2013.zip")

download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2012/FHF_Final_12132012.zip",
          dest = "mountain_pine_beetle\\2012.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\2012.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2012")
file.remove ("mountain_pine_beetle\\2012.zip")

download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2011/final_2011_aos_July30.zip",
          dest = "mountain_pine_beetle\\2011.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\2011.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2011")
file.remove ("mountain_pine_beetle\\2011.zip")

download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2010/fhdata%20final%2012162010.zip",
          dest = "mountain_pine_beetle\\2010.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\2010.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2010")
file.remove ("mountain_pine_beetle\\2010.zip")

download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2009/replacement%20spatial%20and%20MDB%20files-20100111.zip",
          dest = "mountain_pine_beetle\\2009.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\2009.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2009")
file.remove ("mountain_pine_beetle\\2009.zip")

download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2008/2008_BC_overview.zip",
          dest = "mountain_pine_beetle\\2008.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\2008.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2008")
file.remove ("mountain_pine_beetle\\2008.zip")

download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2007/final_version/fhf_shapefiles_20080103.zip",
          dest = "mountain_pine_beetle\\2007.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\2007.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2007")
file.remove ("mountain_pine_beetle\\2007.zip")

download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2006/fhdata_2006_final.zip",
          dest = "mountain_pine_beetle\\2006.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\2006.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2006")
file.remove ("mountain_pine_beetle\\2006.zip")

download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2005/Final/fhfdata_2005.zip",
          dest = "mountain_pine_beetle\\2005.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\2005.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2005")
file.remove ("mountain_pine_beetle\\2005.zip")

download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2004/fhf_complete_dataset_20050218.zip",
          dest = "mountain_pine_beetle\\2004.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\2004.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2004")
file.remove ("mountain_pine_beetle\\2004.zip")

download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2003/fhdata_2003_20040223/2003_AOS_shapefiles.zip",
          dest = "mountain_pine_beetle\\2003.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\2003.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2003")
file.remove ("mountain_pine_beetle\\2003.zip")

download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2002/fhf-nov15-2002.zip",
          dest = "mountain_pine_beetle\\2002.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\2002.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2002")
file.remove ("mountain_pine_beetle\\2002.zip")

download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2001/shape_files/fhdata2001.zip",
          dest = "mountain_pine_beetle\\2001.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\2001.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2001")
file.remove ("mountain_pine_beetle\\2001.zip")

download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/2000/provincial_data/shape.zip",
          dest = "mountain_pine_beetle\\2000.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\2000.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\2000")
file.remove ("mountain_pine_beetle\\2000.zip")

download ("https://www.for.gov.bc.ca/ftp/HFP/external/!publish/Aerial_Overview/1999/shape/Prov_Shape.zip",
          dest = "mountain_pine_beetle\\1999.zip", 
          mode = "wb")
unzip ("mountain_pine_beetle\\1999.zip", 
       exdir = "C:\\Work\\caribou\\clus_data\\mountain_pine_beetle\\1999")
file.remove ("mountain_pine_beetle\\1999.zip")
# NAmes in gdb: mpb_2017 to mpb_1999

###########################
# Caribou telemetry data #
#########################
# Started with BCGW sensitive telemetry data
WHSE_WILDLIFE_INVENTORY.SPI_TELEMETRY_OBS_ALL_SP
SCIENTIFIC_NAME = 'Rangifer tarandus'
# saved to T:\FOR\VIC\HTS\ANA\PROJECTS\CLUS\Data\caribou\telemetry_habitat_model_20180904\caribou_telemetry_master_20180904.gdb'
  # Name in gdb: caribou_spi_obs_all_20180409
  # added field 'source' = "SPI"

# need to reconcile this with each other telemetry dataseta and capture files....ughh.....

# BC OGRIS; README: <http://www.bcogris.ca/sites/default/files/bc-ogrisremb-telemetry-data-read-me-first-ver-3-dec17.pdf>
download ("http://www.bcogris.ca/sites/default/files/webexportcaribou.xlsx", 
          dest = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904\\boreal\\boreal_caribou_telemetry_2011_2018.xlsx", 
          mode = "wb") # downloaded 2018-09-04
# created spatial object in ArcGIS and added to gdb:
# 'T:\FOR\VIC\HTS\ANA\PROJECTS\CLUS\Data\caribou\telemetry_habitat_model_20180904\caribou_telemetry_master_20180904.gdb'
# Name in gdb: caribou_boreal_ogris_2011_2018_20180409
  # NOTE: no overlap with SPI
  # 'source' = "OGRIS"

# Additional data provided by Nicola Dodd
# \\spatialfiles.bcgov\work\env\esd\eis\wld\caribou\nldodd_work\caribou\telem_data\BCtelem_draft\Telem_all_herd_summary
  # Telemetry  - Level-Kawdy 2013
    # Not in SPI; 
      # Name in gdb: caribou_level_kawdy_bcalbers_20180409
      # NOTE: few locatons/animal so likely to serve as validation data
      # source = "levelkawdy"
  # Telemetry - Boreal (all herds) 2009-2012
    # Nexen Final GPS Masterfile_Oct2010_copy to M Watters; see capture file: calendar_nexen_capture_2008
    # Name in gdb: caribou_boreal_nexen_bcalbers_20180409
    # NOTE: no overlap with spi
    # source = "nexen"
  # Telemetry - Burnt Pine - 2003-2012
    # NOTE: no overlap with spi
    # Name in gdb: caribou_burnt_pine_2003_2010_bcalbers_20180906
    # Name in gdb: caribou_burnt_pine_2011_2012_bcalbers_20180906
    # source = "burntpine"
  # Telemetry - Kennedy Siding - 2002-2018
    # 2002-2011 file includes some caribou in SPI; only added car095-099, 118-121 and 127-131
      # Name in gdb: caribou_kennedy_2002_2011_bcalbers_20180906
    # 2012-2018 file are all new data
      # Name in gdb: caribou_kennedy_2012_2018_bcalbers_20180906
    # source = "kennedy"
  # Telemetry - Moberly - 2002-2012
    # 2002-2011 file includes some caribou in SPI; only added car103, 104 and 116
      # Name in gdb: caribou_moberly_bcalbers_20180910
    # 2011-2012 file are all new data
      # Name in gdb: caribou_moberly_2011_2012_bcalbers_20180910
    # source = "moberly"
  # Telemetry - Muskwa 2017
    # Location data in Muskwa Caribou Collars masterfile; some location coordinates missing; deleted these rows
    # Link to capture data in CaribouMuskwa_Master_2 through TelemetryObs_March2017 tab
    # GMT time and local time are the same, so time needs to be converted from GMT
      # Name in gdb: caribou_muskwa_bclabers_20180911
    # source = "muskwa"
  # Telemetry - Narraway - 2006-2018
    # 2006-2009 file all in SPI
    # 2010-2018 file includes some caribou in SPI; only added car177, 178 and 179
      # Name in gdb: caribou_narraway_bcalbers_20180911
    # source = "narraway"
  # Telemetry - Quintette - 2002-2018
    # 2002-2011 file includes some caribou in SPI; only added car106, 107, 110, 111, 113, 114, 125, 126
        # Name in gdb: caribou_quintette_bcalbers_20180911
    # 2011-2018 area all new data
        # Name in gdb: caribou_quintette_2011_2018_bcalbers_20180911
    # source = "quintette"
  # Telemetry - Scott - 2013-2016
    # all new data
      # Name in gdb: caribou_scott_bcalbers_20180911
    # source = "scott"
  # Telemetry - Telkwa
    # Took GPS data from caribou Access database; only one animal from after 2008 (TC009)
      # Name in gdb: caribou_telkwa_bcalbers_20180911
    # source = "telkwa"
# Needed to convert SPI data from MULTIPOINT to POINT (https://support.esri.com/en/technical-article/000007983)
  # Name in gdb: caribou_spi_obs_all_point_20180912

locs.caribou.spi <- sf::st_read (dsn = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904\\caribou_telemetry_master_20180904.gdb",
                                 layer = "caribou_spi_obs_all_point_20180912") 
locs.caribou.spi.slim <-  dplyr::select (locs.caribou.spi, ANIMAL_ID, OBSERVATION_DATETIME, 
                                         OBSERVATION_DATE, OBSERVATION_YEAR, OBSERVATION_MONTH, 
                                         OBSERVATION_DAY, LATITUDE, LONGITUDE, source)

locs.caribou.ogris <- sf::st_read (dsn = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904\\caribou_telemetry_master_20180904.gdb",
                                   layer = "caribou_boreal_ogris_2011_2018_20180409") 
locs.caribou.ogris.slim <-  dplyr::select (locs.caribou.ogris, ANIMAL_ID, OBSERVATION_DATETIME, 
                                           OBSERVATION_DATE, OBSERVATION_YEAR, Latitude, Longitude, 
                                           source)
locs.caribou.ogris.slim$OBSERVATION_MONTH <- month (locs.caribou.ogris.slim$OBSERVATION_DATE)
locs.caribou.ogris.slim$OBSERVATION_DAY <- day (locs.caribou.ogris.slim$OBSERVATION_DATE)
names (locs.caribou.ogris.slim) [5] <- "LATITUDE"
names (locs.caribou.ogris.slim) [6] <- "LONGITUDE"
names (locs.caribou.ogris.slim) [8] <- "GEOMETRY" # make the 'geometry' column the same name as SPI
st_geometry (locs.caribou.ogris.slim) <- "GEOMETRY" # redefine the geometry column from 'shape' to 'geometry'

# not using level-kawdy data
locs.caribou.nexen <- sf::st_read (dsn = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904\\caribou_telemetry_master_20180904.gdb",
                                   layer = "caribou_boreal_nexen_bcalbers_20180409") 
locs.caribou.nexen.slim <-  dplyr::select (locs.caribou.nexen, ANIMAL_ID, OBSERVATION_DATETIME, 
                                           OBSERVATION_DATE, OBSERVATION_YEAR, OBSERVATION_MONTH,
                                           OBSERVATION_DAY, LATITUDE, LONGITUDE, source)
names (locs.caribou.nexen.slim) [10] <- "GEOMETRY" # give the 'geometry' column the same name as SPI
st_geometry (locs.caribou.nexen.slim) <- "GEOMETRY"

locs.caribou.bp2010 <- sf::st_read (dsn = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904\\caribou_telemetry_master_20180904.gdb",
                                    layer = "caribou_burnt_pine_2003_2010_bcalbers_20180906") 
locs.caribou.bp2010.slim <-  dplyr::select (locs.caribou.bp2010, ANIMAL_ID, OBSERVATION_DATETIME, 
                                            OBSERVATION_DATE, OBSERVATION_YEAR, OBSERVATION_MONTH,
                                            OBSERVATION_DAY, LATITUDE, LONGITUDE, source)
names (locs.caribou.bp2010.slim) [10] <- "GEOMETRY" # give the 'geometry' column the same name as SPI
st_geometry (locs.caribou.bp2010.slim) <- "GEOMETRY"

locs.caribou.bp2012 <- sf::st_read (dsn = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904\\caribou_telemetry_master_20180904.gdb",
                                    layer = "caribou_burnt_pine_2011_2012_bcalbers_20180906") 
locs.caribou.bp2012.slim <-  dplyr::select (locs.caribou.bp2012, ANIMAL_ID, OBSERVATION_DATETIME, 
                                            OBSERVATION_DATE, OBSERVATION_YEAR, OBSERVATION_MONTH,
                                            OBSERVATION_DAY, Latitude, Longitude, source)
names (locs.caribou.bp2012.slim) [7] <- "LATITUDE"
names (locs.caribou.bp2012.slim) [8] <- "LONGITUDE"
names (locs.caribou.bp2012.slim) [10] <- "GEOMETRY" # give the 'geometry' column the same name as SPI
st_geometry (locs.caribou.bp2012.slim) <- "GEOMETRY"

locs.caribou.ks2011 <- sf::st_read (dsn = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904\\caribou_telemetry_master_20180904.gdb",
                                    layer = "caribou_kennedy_2002_2011_bcalbers_20180906") 
locs.caribou.ks2011.slim <-  dplyr::select (locs.caribou.ks2011, ANIMAL_ID, OBSERVATION_DATETIME, 
                                            OBSERVATION_DATE, OBSERVATION_YEAR, OBSERVATION_MONTH,
                                            OBSERVATION_DAY, LATITUDE, LONGITUDE, source)
names (locs.caribou.ks2011.slim) [10] <- "GEOMETRY" # give the 'geometry' column the same name as SPI
st_geometry (locs.caribou.ks2011.slim) <- "GEOMETRY"

locs.caribou.ks2011 <- sf::st_read (dsn = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904\\caribou_telemetry_master_20180904.gdb",
                                    layer = "caribou_kennedy_2002_2011_bcalbers_20180906") 
locs.caribou.ks2011.slim <-  dplyr::select (locs.caribou.ks2011, ANIMAL_ID, OBSERVATION_DATETIME, 
                                            OBSERVATION_DATE, OBSERVATION_YEAR, OBSERVATION_MONTH,
                                            OBSERVATION_DAY, LATITUDE, LONGITUDE, source)
names (locs.caribou.ks2011.slim) [10] <- "GEOMETRY" # give the 'geometry' column the same name as SPI
st_geometry (locs.caribou.ks2011.slim) <- "GEOMETRY"

locs.caribou.ks2018 <- sf::st_read (dsn = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904\\caribou_telemetry_master_20180904.gdb",
                                    layer = "caribou_kennedy_2012_2018_bcalbers_20180906") 
locs.caribou.ks2018.slim <-  dplyr::select (locs.caribou.ks2018, ANIMAL_ID, OBSERVATION_DATETIME, 
                                            OBSERVATION_DATE, OBSERVATION_YEAR, OBSERVATION_MONTH,
                                            OBSERVATION_DAY, LATITUDE, LONGITUDE, source)
names (locs.caribou.ks2018.slim) [10] <- "GEOMETRY" # give the 'geometry' column the same name as SPI
st_geometry (locs.caribou.ks2018.slim) <- "GEOMETRY"

locs.caribou.moberly <- sf::st_read (dsn = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904\\caribou_telemetry_master_20180904.gdb",
                                     layer = "caribou_moberly_bcalbers_20180910") 
locs.caribou.moberly.slim <-  dplyr::select (locs.caribou.moberly, ANIMAL_ID, OBSERVATION_DATETIME, 
                                             OBSERVATION_DATE, OBSERVATION_YEAR, OBSERVATION_MONTH,
                                             OBSERVATION_DAY, LATITUDE, LONGITUDE, source)
names (locs.caribou.moberly.slim) [10] <- "GEOMETRY" # give the 'geometry' column the same name as SPI
st_geometry (locs.caribou.moberly.slim) <- "GEOMETRY"

locs.caribou.moberly2012 <- sf::st_read (dsn = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904\\caribou_telemetry_master_20180904.gdb",
                                         layer = "caribou_moberly_2011_2012_bcalbers_20180910") 
locs.caribou.moberly2012$OBSERVATION_MONTH <- month (locs.caribou.moberly2012$OBSERVATION_DATE)
locs.caribou.moberly2012$OBSERVATION_DAY <- day (locs.caribou.moberly2012$OBSERVATION_DATE)
locs.caribou.moberly2012$OBSERVATION_YEAR <- year (locs.caribou.moberly2012$OBSERVATION_DATE)
locs.caribou.moberly2012.slim <-  dplyr::select (locs.caribou.moberly2012, ANIMAL_ID, 
                                                 OBSERVATION_DATETIME, OBSERVATION_DATE, 
                                                 OBSERVATION_YEAR, OBSERVATION_MONTH,
                                                 OBSERVATION_DAY, Latitude, Longitude, source)
names (locs.caribou.moberly2012.slim) [7] <- "LATITUDE"
names (locs.caribou.moberly2012.slim) [8] <- "LONGITUDE"
names (locs.caribou.moberly2012.slim) [10] <- "GEOMETRY" 
st_geometry (locs.caribou.moberly2012.slim) <- "GEOMETRY"

locs.caribou.muskwa <- sf::st_read (dsn = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904\\caribou_telemetry_master_20180904.gdb",
                                    layer = "caribou_muskwa_bclabers_20180911") 
locs.caribou.muskwa.slim <-  dplyr::select (locs.caribou.muskwa, ANIMAL_ID, 
                                            OBSERVATION_DATETIME, OBSERVATION_DATE, 
                                            OBSERVATION_YEAR, OBSERVATION_MONTH,
                                            OBSERVATION_DAY, latitude, longitude, source)
locs.caribou.muskwa.slim$OBSERVATION_DATE <- as.Date (format (locs.caribou.muskwa.slim$OBSERVATION_DATETIME, 
                                                              "%Y/%m/%d"))
names (locs.caribou.muskwa.slim) [7] <- "LATITUDE"
names (locs.caribou.muskwa.slim) [8] <- "LONGITUDE"
names (locs.caribou.muskwa.slim) [10] <- "GEOMETRY" 
st_geometry (locs.caribou.muskwa.slim) <- "GEOMETRY"

locs.caribou.narraway <- sf::st_read (dsn = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904\\caribou_telemetry_master_20180904.gdb",
                                      layer = "caribou_narraway_bcalbers_20180911") 
locs.caribou.narraway.slim <-  dplyr::select (locs.caribou.narraway, ANIMAL_ID, 
                                              OBSERVATION_DATETIME, OBSERVATION_DATE, 
                                              OBSERVATION_YEAR, OBSERVATION_MONTH,
                                              OBSERVATION_DAY, LATITUDE, LONGITUDE, source)
names (locs.caribou.narraway.slim) [10] <- "GEOMETRY" 
st_geometry (locs.caribou.narraway.slim) <- "GEOMETRY"

locs.caribou.quin <- sf::st_read (dsn = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904\\caribou_telemetry_master_20180904.gdb",
                                  layer = "caribou_quintette_bcalbers_20180911") 
locs.caribou.quin.slim <-  dplyr::select (locs.caribou.quin, ANIMAL_ID, 
                                          OBSERVATION_DATETIME, OBSERVATION_DATE, 
                                          OBSERVATION_YEAR, OBSERVATION_MONTH,
                                          OBSERVATION_DAY, LATITUDE, LONGITUDE, source)
names (locs.caribou.quin.slim) [10] <- "GEOMETRY" 
st_geometry (locs.caribou.quin.slim) <- "GEOMETRY"

locs.caribou.quin2018 <- sf::st_read (dsn = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904\\caribou_telemetry_master_20180904.gdb",
                                      layer = "caribou_quintette_2011_2018_bcalbers_20180911") 
locs.caribou.quin2018.slim <-  dplyr::select (locs.caribou.quin2018, ANIMAL_ID, 
                                              OBSERVATION_DATETIME, OBSERVATION_DATE, 
                                              OBSERVATION_YEAR, OBSERVATION_MONTH,
                                              OBSERVATION_DAY, LATITUDE, LONGITUDE, source)
names (locs.caribou.quin2018.slim) [10] <- "GEOMETRY" 
st_geometry (locs.caribou.quin2018.slim) <- "GEOMETRY"

locs.caribou.scott <- sf::st_read (dsn = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904\\caribou_telemetry_master_20180904.gdb",
                                   layer = "caribou_scott_bcalbers_20180911") 
locs.caribou.scott.slim <-  dplyr::select (locs.caribou.scott, ANIMAL_ID, 
                                           OBSERVATION_DATETIME, OBSERVATION_DATE, 
                                           OBSERVATION_YEAR, OBSERVATION_MONTH,
                                           OBSERVATION_DAY, LATITUDE, LONGITUDE, source)
names (locs.caribou.scott.slim) [10] <- "GEOMETRY" 
st_geometry (locs.caribou.scott.slim) <- "GEOMETRY"

locs.caribou.telkwa <- sf::st_read (dsn = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904\\caribou_telemetry_master_20180904.gdb",
                                   layer = "caribou_telkwa_bcalbers_20180911") 
locs.caribou.telkwa.slim <-  dplyr::select (locs.caribou.telkwa, Animal_ID, 
                                            OBSERVATION_DATETIME, OBSERVATION_DATE, 
                                            OBSERVATION_YEAR, OBSERVATION_MONTH,
                                            OBSERVATION_DAY, Latitude, Longitude, source)
names (locs.caribou.telkwa.slim) [1] <- "ANIMAL_ID"
names (locs.caribou.telkwa.slim) [7] <- "LATITUDE"
names (locs.caribou.telkwa.slim) [8] <- "LONGITUDE"
names (locs.caribou.telkwa.slim) [10] <- "GEOMETRY" 
st_geometry (locs.caribou.telkwa.slim) <- "GEOMETRY"

locs.caribou.all <- rbind (locs.caribou.spi.slim, locs.caribou.ogris.slim, locs.caribou.nexen.slim,
                           locs.caribou.bp2010.slim, locs.caribou.bp2012.slim,
                           locs.caribou.ks2011.slim, locs.caribou.ks2018.slim, 
                           locs.caribou.moberly.slim, locs.caribou.moberly2012.slim,
                           locs.caribou.muskwa.slim, locs.caribou.narraway.slim, 
                           locs.caribou.quin.slim, locs.caribou.quin2018.slim, locs.caribou.scott.slim,
                           locs.caribou.telkwa.slim)

rm (locs.caribou.spi, locs.caribou.spi.slim, locs.caribou.ogris,locs.caribou.ogris.slim, 
    locs.caribou.nexen, locs.caribou.nexen.slim, locs.caribou.bp2010, locs.caribou.bp2010.slim,
    locs.caribou.bp2012, locs.caribou.bp2012.slim, locs.caribou.ks2011, locs.caribou.ks2011.slim,
    locs.caribou.ks2018, locs.caribou.ks2018.slim, locs.caribou.moberly, locs.caribou.moberly.slim,
    locs.caribou.moberly2012, locs.caribou.moberly2012.slim, locs.caribou.muskwa, 
    locs.caribou.muskwa.slim, locs.caribou.narraway, locs.caribou.narraway.slim, locs.caribou.quin,
    locs.caribou.quin.slim, locs.caribou.quin2018, locs.caribou.quin2018.slim, locs.caribou.scott,
    locs.caribou.scott.slim, locs.caribou.telkwa, locs.caribou.telkwa.slim)
gc ()

# abbreviate fields for saving as shapefile as back-up
names (locs.caribou.all) [1] <- "animal_id"
names (locs.caribou.all) [2] <- "datetime"
names (locs.caribou.all) [3] <- "date"
names (locs.caribou.all) [4] <- "year"
names (locs.caribou.all) [5] <- "month"
names (locs.caribou.all) [6] <- "day"

st_write (obj = locs.caribou.all, 
          dsn = "C:\\Work\\caribou\\clus_data\\caribou\\telemetry_habitat_model_20180904", 
          layer = "telemetry_caribou_all", driver = "ESRI Shapefile")

conn <- dbConnect (dbDriver ("PostgreSQL"), 
                   host = "",
                   user = "postgres",
                   dbname = "postgres",
                   password = "postgres",
                   port = "5432")
st_write (obj = locs.caribou, 
          dsn = conn, 
          layer = c ("caribou", "telemetry_caribou_all"))
dbDisconnect (conn)

connKyle <- dbConnect(drv = RPostgreSQL::PostgreSQL(), 
                      host = key_get('dbhost', keyring = 'postgreSQL'),
                      user = key_get('dbuser', keyring = 'postgreSQL'),
                      dbname = key_get('dbname', keyring = 'postgreSQL'),
                      password = key_get('dbpass', keyring = 'postgreSQL'),
                      port = "5432")
st_write (obj = locs.caribou, 
          dsn = connKyle, 
          layer = c ("caribou", "telemetry_caribou_all"))
dbDisconnect (connKyle)

