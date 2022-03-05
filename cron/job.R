library(sf)
library(wastdr)

fn_wastd_sites <- here::here("inst/wastd_sites.rds")
fn_wastd_data <- here::here("inst/wastd_data.rds")
fn_w2_data <- here::here("inst/w2_data.rds")

# WAStD Areas and Sites - 10 sec ----------------------------------------------#

"[{Sys.time()}] Downloading WAStD Sites to {fn_wastd_sites}" %>%
  glue::glue() %>%
  wastdr::wastdr_msg_info()
sites <- wastdr::download_wastd_sites()
saveRDS(sites, file = fn_wastd_sites)
"[{Sys.time()}] WAStD Data saved locally to {fn_wastd_sites}." %>%
  glue::glue() %>%
  wastdr::wastdr_msg_success()

# WAMTRAM data - 2 mins -------------------------------------------------------#
if (wastdr::w2_online() == FALSE) {
  "[{Sys.time()}] WAMTRAM not accessible. Need to run in DBCA intranet with credentials in env vars." %>%
    glue::glue() %>%
    wastdr::wastdr_msg_info()
} else {
  "[{Sys.time()}] Downloading WAMTRAM Data to {fn_w2_data}" %>%
    glue::glue() %>%
    wastdr::wastdr_msg_info()

  w2_data <- wastdr::download_w2_data(save = fn_w2_data)

  "[{Sys.time()}] WAMTRAM Data saved locally to folder {fn_w2_data}." %>%
    glue::glue() %>%
    wastdr::wastdr_msg_success()
}

# WAStD data - 40 mins --------------------------------------------------------#
"[{Sys.time()}] Downloading WAStD Data to {fn_wastd_data}" %>%
  glue::glue() %>%
  wastdr::wastdr_msg_info()

wastd_data <- wastdr::download_wastd_turtledata()
saveRDS(wastd_data, file = fn_wastd_data)

"[{Sys.time()}] WAStD Data saved locally to folder {fn_wastd_data}." %>%
  glue::glue() %>%
  wastdr::wastdr_msg_success()
