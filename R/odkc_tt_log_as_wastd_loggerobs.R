#' Transform odkc_data$tt_log into WAStD LoggerObservations.
#'
#' @param data A tibble of logger observations from turtle tagging,
#'   e.g. \code{odkc_data$tt_log}.
#' @return A tibble suitable to
#'   \code{\link{wastd_POST}("logger-observations")}
#' @export
#' @examples
#' \dontrun{
#' data("odkc_data", package = "wastdr")
#' data("wastd_data", package = "wastdr")
#' au <- Sys.getenv("WASTDR_API_DEV_URL")
#' at <- Sys.getenv("WASTDR_API_DEV_TOKEN")
#' x <- odkc_tt_as_wastd_loggerobs(odkc_data$tt_log)
#' x %>% wastd_POST("logger-observations", api_url = au, api_token = at)
#' }
odkc_tt_log_as_wastd_loggerobs <- function(data) {

  data %>%
    dplyr::transmute(
      source = 2,
      source_id = id,
      encounter_source="odk",
      encounter_source_id = submissions_id,
      logger_type = logger_type,
      deployment_status = logger_status,
      logger_id = logger_name,
      comments = logger_comments
    ) %>%
    dplyr::filter_at(
      dplyr::vars(-source, -source_id, -encounter_source, -encounter_source_id),
      dplyr::any_vars(!is.na(.))
    )

}

# usethis::use_test("odkc_tt_log_as_wastd_loggerobs")
