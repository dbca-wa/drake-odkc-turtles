
<!-- README.md is generated from README.Rmd. Please edit that file -->

# etlTurtleNesting

<!-- badges: start -->

<!-- badges: end -->

The package etlTurtleNesting contains the ETL and QA for Turtle Nesting
Census data from ODK Central to WAStD.

Issues are tracked at
[wastdr](https://github.com/dbca-wa/wastdr/milestone/1).

## Installation

You can install etlTurtleNesting from [GitHub](https://github.com/)
with:

``` r
remotes::install_github("dbca-wa/etlTurtleNesting")
```

## Add new users

New users can be added to WAStD in batches before each field season.
Local coordinators will provide a spreadsheet with columns “name” (full
name, correct\! spelling and capitalisation), “email”, “phone”.

The spreadsheet is post-processed:

  - Open with option “quoted columns as text”
  - username (A), name (B), email, phone, role (C-E)
  - Formula for username: `=SUBSTITUTE(LOWER(B2), " ", "_")`
  - Format phone as text and prefix with +61
  - Save as CSV with “quote all text columns”

<!-- end list -->

``` r
# Step 1: New users (username, name, phone, email, role)
# HTTP status returned: 400 for existing, 201 for new
# Append new users to spreadsheet: username, name, email, phone, role
library(wastdr)
users <- here::here("inst/users_nin2020.csv") %>%
 readr::read_csv(col_types = "ccccc") %>%
 wastdr::wastd_bulk_post("users", verbose = TRUE)
```

## Import ODKC data, export WAStD data, create reports and outputs

Run `run.R` as a local job. Full data export and reporting are already
part of `run.R`.

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
