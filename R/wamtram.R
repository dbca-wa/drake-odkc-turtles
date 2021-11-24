#' Top-level Turtle Tagging data import Drake Plan
#'
#' * Download all turtle tagging data (no attachments)
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
#'
#' library(etlTurtleNesting)
#' library(wastdr)
#' library(drake)
#'
#' drake::loadd("w2_data")
#'
#' wamtram()
#' visNetwork::visSave(vis_drake_graph(wamtram()), "drake_graph.html")
#' drake::vis_drake_graph(wamtram())
#' drake::clean()
#' drake::clean("w2_data")
#' drake::make(plan = wamtram(), targets = c("user_qa"))
#' drake::make(wamtram(), lock_envir = FALSE)
#'
#' deps_code(quote(knitr_in("doc/qa_sites_w2.Rmd")))
#' deps_code(quote(knitr_in("doc/qa_users_w2.Rmd")))
#' }
wamtram <- function() {
  drake::drake_plan(
    # ------------------------------------------------------------------------ #
    # SETUP
    dl_w2 = Sys.getenv("W2_DOWNLOAD", unset = TRUE),
    wastd_data_yr = Sys.getenv("WASTD_YEAR", unset = 1900L),
    w2_yr = Sys.getenv("W2_YEAR", unset = 2020L),
    up_ex = Sys.getenv("W2_IMPORT_UPDATE_EXISTING", unset = FALSE),

    # ------------------------------------------------------------------------ #
    # EXTRACT
    # saveRDS(w2, file = here::here("data-raw/w2.rds"), compress="xz")
    w2_data = readRDS(here::here("data/w2.rds")),
    # w2_data = wastdr::download_w2_data(
    #   ord = c("YmdHMS", "Ymd"),
    #   tz = "Australia/Perth",
    #   db_drv = Sys.getenv("W2_DRV"),
    #   db_srv = Sys.getenv("W2_SRV"),
    #   db_name = Sys.getenv("W2_DB"),
    #   db_user = Sys.getenv("W2_UN"),
    #   db_pass = Sys.getenv("W2_PW"),
    #   db_port = Sys.getenv("W2_PT"),
    #   verbose = wastdr::get_wastdr_verbose()
    # ),

    # ------------------------------------------------------------------------ #
    # TRANSFORM
    wastd_users = wastdr::download_wastd_users(),
    w2_user_mapping = make_user_mapping_w2(w2_data, wastd_users),

    # QA Reports: inspect user mappings - flag dissimilar matches
    # https://github.com/dbca-wa/wastdr/issues/21
    user_qa = generate_qa_users_report_w2(w2_user_mapping, w2_yr, w2_data),

    # Resume:
    # load("data/w2dev.RData")
    #
    # Source data transformed into target format
    w2_tf = w2_as_wastd(w2_data, w2_user_mapping),
    # Sites
    # site_qa = generate_qa_sites_report_w2(w2_data, w2_tf, w2_yr),

    # ------------------------------------------------------------------------ #
    # LOAD
    wastd_data_min = wastdr::download_minimal_wastd_turtledata(year = wastd_data_yr),
    # Skip logic compares existing data in target DB with new data to upload
    w2_up = split_create_update_skip_w2(w2_tf, wastd_data_min)
    # Upload (skip, update, create as per skip logic)
    # upload_to_wastd = upload_w2_to_wastd(w2_up, update_existing = up_ex)
  )
}

# usethis::use_r("wamtram")
