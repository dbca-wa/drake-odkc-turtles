# Setup -----------------------------------------------------------------------#
library(etlTurtleNesting)
library(sf)
library(wastdr)
library(magrittr)
library(lubridate)
library(glue)
library(drake)
library(ruODK)

# Absolute paths to saved data and config files -------------------------------#
fn_odk <- "/app/inst/odk.txt"
fn_wastd_sites <- "/app/inst/wastd_sites.rds"
fn_wastd_data <- "/app/inst/wastd_data.rds"
fn_w2_data <- "/app/inst/w2_data.rds"
fn_renv <- "/app/config/.Renviron"

# Gate checks -----------------------------------------------------------------#
# There are two mounted persistent volumes, one for data, the other for config.
# If the data directory does not exist, the save functions below will fail.
print("Shared data directory exists:")
print(fs::dir_exists("/app/inst/"))

print("Persistent config directory exists:")
print(fs::dir_exists("/app/config/"))

# The file .Renviron has to be created once manually through a shell into the
# running container, pasting in any environment variables we need for the script.
print("Persisted .Renviron exists:")
print(fs::file_exists(fn_renv))

# Since out .Renviron is not in a default location, we have to read it explicitly.
# The non-default location of .Renviron allows to mount a persistent volume
# containing the .Renviron to a (non-standard) folder, here "/app/config".
# This avoids collisions between the mounted volume and other files in the
# target folder inside the running Docker container.
readRenviron(fn_renv)

# This should indicate whether the environment variables have been read.
print("wastdr settings:")
print(wastdr::wastdr_settings())

print("ruODK settings:")
print(ruODK::ru_settings())

# ODK to WAStD import ---------------------------------------------------------#
"[{Sys.time()}] Importing ODK to WAStD" %>% glue::glue() %>% print()

Sys.setenv(ODKC_IMPORT_UPDATE_EXISTING=FALSE)
drake::clean()
drake::make(odkc2020(), lock_envir = FALSE)

writeLines(lubridate::format_ISO8601(Sys.time()), fn_odk)

"[{Sys.time()}] ODK Data imported to WAStD." %>% glue::glue() %>% print()

# WAStD Areas and Sites - 10 sec ----------------------------------------------#
"[{Sys.time()}] Downloading WAStD Sites to {fn_wastd_sites}" %>%
  glue::glue() %>%
  print()

sites <- wastdr::download_wastd_sites(save=fn_wastd_sites, compress=FALSE)

"[{Sys.time()}] WAStD Data saved locally to {fn_wastd_sites}." %>%
  glue::glue() %>%
  print()

# WAMTRAM data - 2 mins -------------------------------------------------------#
if (wastdr::w2_online() == FALSE) {
  "[{Sys.time()}] WAMTRAM not accessible. Need to run in DBCA intranet with credentials in env vars." %>%
    glue::glue() %>%
    print()
} else {
  "[{Sys.time()}] Downloading WAMTRAM Data to {fn_w2_data}" %>%
    glue::glue() %>%
    print()

  w2_data <- wastdr::download_w2_data(save = fn_w2_data, compress=FALSE)

  "[{Sys.time()}] WAMTRAM Data saved locally to folder {fn_w2_data}." %>%
    glue::glue() %>%
    print()
}

# WAStD data - 40 mins --------------------------------------------------------#
"[{Sys.time()}] Downloading WAStD Data to {fn_wastd_data}" %>%
  glue::glue() %>%
  print()

wastd_data <- wastdr::download_wastd_turtledata(save=fn_wastd_data, compress=FALSE)

"[{Sys.time()}] WAStD Data saved locally to folder {fn_wastd_data}." %>%
  glue::glue() %>%
  print()
