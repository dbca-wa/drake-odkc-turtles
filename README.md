
<!-- README.md is generated from README.Rmd. Please edit that file -->

# etlTurtleNesting

<!-- badges: start -->

[![docker](https://github.com/dbca-wa/etlTurtleNesting/actions/workflows/docker.yaml/badge.svg)](https://github.com/dbca-wa/etlTurtleNesting/actions/workflows/docker.yaml)
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

## Run the WAMTRAM geolocation QA dashboard

### Running the dashboard

Either open “vignettes/qa\_wamtram\_geolocation.Rmd” and click “Run
Document”, or run

``` r
rmarkdown::run(here::here("vignettes/qa_wamtram_geolocation.Rmd"), shiny_args = list(port = 3838, host = "0.0.0.0"))
```

Follow instructions on the last tab (protocols) to update WAMTRAM
through its admin front-end.

### Refresh WAMTRAM data

After a while of updating WAMTRAM, you’ll want to see these updates
reflected in the dashboard. To refresh WAMTRAM data, stop the running
dashboard, then run the command below in the console, restart the R
session (<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>F10</kbd>) then restart
the dashboard (<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>K</kbd>).

``` r
w2_data <- wastdr::download_w2_data(save=here::here("inst/w2.rds"))
```

### Update wastdr

When instructed to upgrade the R package `wastdr` which does most of the
work under the bonnet, run:

``` r
remotes::install_github("dbca-wa/wastdr", dependencies = TRUE, upgrade = "never", build_vignettes = TRUE)
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

## Run ODKC data import in the cloud

This repo contains a Dockerfile to build an image containing a cron job
running the data import as well as download and export of data from
WAStD and WAMTRAM as needed by `turtleviewer2`.

The build process is identical to that of `turtleviewer2`.

## Development and local testing

Build Docker image for local testing:

``` bash
docker build . -t dbca-wa/etlTurtleNesting:latest
```

Inspect the locally built image for debugging:

``` bash
docker run -it dbca-wa/etlTurtleNesting:latest /bin/bash -c "export TERM=xterm; exec bash"
```

### Deployment

Once app and Docker image work, create a new version, tag, and push the
tag.

``` r
# One of these (R console)
usethis::use_version(which="patch")
usethis::use_version(which="minor")
usethis::use_version(which="major")

styler::style_pkg()
spelling::spell_check_package()
spelling::update_wordlist()

# Code and docs tested, working, committed
usethis::use_version()
usethis::edit_file("NEWS.md")

# Git commit, then tag and push
devtools::document()
v <- packageVersion("etlTurtleNesting")
system(glue::glue("git tag -a v{v} -m 'v{v}'"))
system(glue::glue("git push && git push --tags"))
```
