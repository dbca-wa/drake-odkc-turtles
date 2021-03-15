#' Top-level Turtle Nesting Census data import Drake Plan
#'
#' * Download all ODKC data including attachments
#' * Load existing nesting records from WAStD: load only a minimal set of
#'   source, source ID, QA status to determine later what to
#'   create / update / skip:
#'   * does not exist in WAStD: create (POST)
#'   * exists in WAStD with status "new": update (PATCH)
#'   * exists in WAStD with status higher than "new": skip (and message)
#'   * Make (transform) ODKC to WAStD data
#'   * Load transformed data into WAStD's API (create/update/skip)
#'   * No QA
#'
#' @export
#' @examples
#' \dontrun{
#'
#' # Step 1: New users (username, name, phone, email, role)
#' # 400 for existing, 201 for new
#' Append new users to spreadsheet: username, name, email, phone, role
#' users <- here::here("users.csv") %>%
#'   readr::read_csv(col_types = "ccccc") %>%
#'   wastdr::wastd_bulk_post("users",
#'   #api_url = Sys.getenv("WASTDR_API_DEV_URL"),
#'   #api_token = Sys.getenv("WASTDR_API_DEV_TOKEN"),
#'   verbose = TRUE)
#'
#' users_dev <- here::here("users.csv") %>%
#'   readr::read_csv(col_types = "ccccc") %>%
#'   wastdr::wastd_bulk_post("users",
#'   api_url = Sys.getenv("WASTDR_API_DEV_URL"),
#'   api_token = Sys.getenv("WASTDR_API_DEV_TOKEN"),
#'   verbose = TRUE)
#'
#' # save point for debug
#' save(atkn, aurl, vbse, updt, odkc_ex, odkc_tf, odkc_up,
#' wastd_data, wastd_users, user_mapping, file="odkc_import.RData")
#' load("odkc_import.RData")
#'
#' wastdr::wastdr_setup(api_url = Sys.getenv("WASTDR_API_DEV_URL"),
#'                      api_token = Sys.getenv("WASTDR_API_DEV_TOKEN"))
#' wastdr::wastdr_setup(api_url = Sys.getenv("WASTDR_API_TEST_URL"),
#'                      api_token = Sys.getenv("WASTDR_API_TEST_TOKEN"))
#' wastdr::wastdr_setup(api_url = Sys.getenv("WASTDR_API_URL"),
#'                      api_token = Sys.getenv("WASTDR_API_TOKEN"))
#' Sys.setenv(ODKC_IMPORT_UPDATE_EXISTING=TRUE)
#' Sys.setenv(ODKC_IMPORT_UPDATE_EXISTING=FALSE)
#' Sys.setenv(ODKC_IMPORT_UPLOAD_MEDIA=TRUE)
#' Sys.setenv(ODKC_IMPORT_UPLOAD_MEDIA=FALSE)
#' Sys.setenv(ODKC_DOWNLOAD=TRUE) # Dl media files
#' Sys.setenv(ODKC_DOWNLOAD=FALSE)
#' Sys.setenv(ODKC_YEAR=2019)
#' Sys.setenv(ODKC_YEAR=2020)
#'
#' library(etlTurtleNesting)
#' library(wastdr)
#' library(drake)
#'
#' odkc2019()
#' visNetwork::visSave(vis_drake_graph(odkc2019()), "etl2019.html")
#' drake::vis_drake_graph(odkc2019())
#' drake::clean()
#' drake::clean("wastd_users") # after updating WAStD user aliases
#' drake::clean("upload_to_wastd")
#' drake::clean("odkc_ex")
#' drake::clean("upload_to_wastd")
#' drake::make(plan = odkc2019(), targets = c("upload_to_wastd"))
#' drake::make(odkc2019(), lock_envir = FALSE)
#'
#' deps_code(quote(knitr_in("doc/qa_sites.Rmd")))
#' deps_code(quote(knitr_in("doc/qa_users.Rmd")))
#' }
odkc2019 <- function() {
  drake::drake_plan(
    # ------------------------------------------------------------------------ #
    # SETUP
    dl_odkc = Sys.getenv("ODKC_DOWNLOAD", unset = TRUE),
    wastd_data_yr = Sys.getenv("WASTD_YEAR", unset = 2019L),
    odkc_yr = Sys.getenv("ODKC_YEAR", unset = 2019L),
    up_ex = Sys.getenv("ODKC_IMPORT_UPDATE_EXISTING", unset = FALSE),
    up_media = Sys.getenv("ODKC_IMPORT_UPLOAD_MEDIA", unset = TRUE),

    # ------------------------------------------------------------------------ #
    # EXTRACT
    odkc_ex = wastdr::download_odkc_turtledata_2019(
      download = dl_odkc, verbose = FALSE),

    # ------------------------------------------------------------------------ #
    # TRANSFORM
    wastd_users = wastdr::download_wastd_users(),
    user_mapping = make_user_mapping(odkc_ex, wastd_users),
    # QA Reports: inspect user mappings - flag dissimilar matches
    # https://github.com/dbca-wa/wastdr/issues/21
    user_qa = generate_qa_users_report(odkc_ex, user_mapping, odkc_yr),
    # Source data transformed into target format
    odkc_tf = odkc_as_wastd(odkc_ex, user_mapping),
    # Sites
    site_qa = generate_qa_sites_report(odkc_ex, odkc_tf, odkc_yr),

    # ------------------------------------------------------------------------ #
    # LOAD
    wastd_data = wastdr::download_minimal_wastd_turtledata(year = wastd_data_yr),
    # Skip logic compares existing data in target DB with new data to upload
    odkc_up = split_create_update_skip(odkc_tf, wastd_data),
    # Upload (skip, update, create as per skip logic)
    upload_to_wastd = upload_odkc_to_wastd(
      odkc_up, update_existing = up_ex, up_media = up_media)
  )
}

