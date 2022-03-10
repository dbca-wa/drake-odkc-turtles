#' Transform odkc_data$tracks_log into WAStD LoggerObservations.
#'
#' @param data A tibble of tracks_log,  e.g. \code{odkc_data$tracks_log}.
#' @return A tibble suitable to
#'   \code{\link{wastd_POST}("logger-observations")}
#' @export
#' @examples
#' \dontrun{
#' data("odkc_data", package = "wastdr")
#' au <- Sys.getenv("WASTDR_API_DEV_URL")
#' at <- Sys.getenv("WASTDR_API_DEV_TOKEN")
#' x <- odkc_tracks_log_as_wastd_loggerobs(odkc_ex$tracks_log)
#' x %>% wastd_POST("logger-observations", api_url = au, api_token = at)
#' }
odkc_tracks_log_as_wastd_loggerobs <- function(data) {
  data %>%
    wastdr::sf_as_tbl() %>%
    dplyr::transmute(
      source = 2,
      source_id = id,
      encounter_source = "odk",
      encounter_source_id = submissions_id,
      logger_type = ifelse( # prepare for ToN 1.4 field logger_type
        "logger_type" %in% names(data),
        logger_type,
        "temperature-logger"
      ),
      deployment_status = ifelse(
        "logger_status" %in% names(data),
        logger_status %>%
          # ToN 1.2 applied-new resighted - need to rename applied-new to deployed
          # ToN 1.3 deployed resighted retrieved
          stringr::str_replace_all("applied-new", "deployed"),
        NA
      ),
      logger_id = logger_id,
      comments = ifelse(
        "logger_details_logger_comments" %in% names(data),
        logger_details_logger_comments,
        ""
      )
    ) %>%
    dplyr::filter_at(
      dplyr::vars(-source, -source_id, -encounter_source, -encounter_source_id),
      dplyr::any_vars(!is.na(.))
    )
}

# usethis::use_test("odkc_tracks_log_as_wastd_loggerobs")
