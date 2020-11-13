
<!-- README.md is generated from README.Rmd. Please edit that file -->

# etlTurtleNesting

<!-- badges: start -->
<!-- badges: end -->

The package etlTurtleNesting contains the ETL and QA for Turtle Nesting
Census data from ODK Central to WAStD.

Issues are tracked at
[wastdr](https://github.com/dbca-wa/wastdr/milestone/1). QA products can
be reviewed at (TBD).

## Installation

You can install etlTurtleNesting from [GitHub](https://github.com/)
with:

``` r
# install.packages("devtools")
devtools::install_github("dbca-wa/etlTurtleNesting")
```

## Add new users

Actions on spreadsheet:

-   Open with option “quoted columns as text”
-   username (A), name (B), email, phone, role (C-E)
-   Formula for username: `=SUBSTITUTE(LOWER(B2), " ", "_")`
-   Format phone as text and prepend with +61
-   Save as CSV with “quote all text columns”

``` r
# Step 1: New users (username, name, phone, email, role)
# 400 for existing, 201 for new
# Append new users to spreadsheet: username, name, email, phone, role
users <- here::here("data/users_nin2020.csv") %>%
 readr::read_csv(col_types = "ccccc") %>%
 wastdr::wastd_bulk_post("users",
 #api_url = Sys.getenv("WASTDR_API_DEV_URL"),
 #api_token = Sys.getenv("WASTDR_API_DEV_TOKEN"),
 verbose = TRUE)
```

## Import 2019-20 data

``` r
library(etlTurtleNesting)
library(wastdr)
library(drake)

odkc2019()

# Show plan
drake::vis_drake_graph(odkc2019())

# Save plan
visNetwork::visSave(vis_drake_graph(odkc2019()), "etl2019.html")

# Reset plan
# Invalidate specific cached steps
# drake::clean("wastd_users") # after updating WAStD user aliases
# or re-run all from the top
drake::clean()

# Run specific steps
# drake::make(plan = odkc2019(), targets = c("upload_to_wastd"))

# Run all
drake::make(odkc2019(), lock_envir = FALSE)
```

## Import 2020-21 data

``` r
# Comprehensive - update everything unless QA'd in WAStD
Sys.setenv(ODKC_IMPORT_UPDATE_EXISTING=TRUE)
Sys.setenv(ODKC_IMPORT_UPDATE_MEDIA=TRUE)
Sys.setenv(ODKC_DOWNLOAD=TRUE) # Dl media files

# Incremental
Sys.setenv(ODKC_IMPORT_UPDATE_EXISTING=FALSE)
Sys.setenv(ODKC_IMPORT_UPDATE_MEDIA=FALSE)
Sys.setenv(ODKC_DOWNLOAD=FALSE)

# Show graph
odkc2020()
drake::vis_drake_graph(odkc2020())
visNetwork::visSave(vis_drake_graph(odkc2020()), "etl2020.html")

# Reset and re-run
drake::clean("odkc_ex")
drake::clean()
drake::make(odkc2020(), lock_envir = FALSE)
```

## Download WAStD Turtledata

``` r
library(wastdr)

# Download all turtledata - long running (30min)
wastd_data_full <- download_wastd_turtledata()

# Save and restore
save(wastd_data_full, file = "wastd_data_full.RData")
load("wastd_data_full.RData")


# Docs on data structure and contents
??wastdr::download_wastd_turtledata

# Review choice of existing turtle program locations
wastd_data_full$areas$area_name

# Target area to filter for, choose from:
a <- "Cape Domett"                                     
a <- "Smokey Bay Area"                                 
a <- "Cable Beach Broome"                              
a <- "Port Hedland"                                    
a <- "Delambre Island"                                 
a <- "Rosemary Island"                                 
a <- "Conzinc Bay"                                     
a <- "West Pilbara Turtle Program beaches Wickam"      
a <- "West Pilbara Turtle Program beaches Caravan Park"
a <- "Barrow Island"                                   
a <- "Thevenard Island"                                
a <- "Ningaloo"                                        
a <- "Onslow"                                          
a <- "Perth Metro" 
a <- "Other" # orphaned records

# Target directory
target_dir <- here::here(wastdr::urlize(a))
target_fn <- wastdr::urlize(a)

# Filter all data down to target area
# wastd_data_filtered <- filter_wastd_turtledata(list(), a) # must fail
wastd_data_filtered <- wastd_data_full %>% filter_wastd_turtledata(a) 
wastd_data_filtered
# Optional: summarise, analyse, visualise (tables, figures, maps)

# Export to a ZIP file
wastd_data_filtered %>% 
  export_wastd_turtledata(outdir = target_dir, filename = target_fn)

# Save to RData for further analysis in R 
# See wastdr helpers for available summaries and maps
save(wastd_data_filtered, file = glue::glue("wastd_data_{target_fn}.RData"))
```
