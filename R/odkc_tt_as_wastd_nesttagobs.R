#' Transform odkc_data$tt into WAStD NestTagObservations.
#'
#' @param data A tibble of turtle tagging data, e.g. \code{odkc_data$tt}.
#' @return A tibble suitable to
#'   \code{\link{wastd_POST}("nest-tag-observations")}
#' @export
#' @examples
#' \dontrun{
#' data("odkc_data", package = "wastdr")
#' au <- Sys.getenv("WASTDR_API_DEV_URL")
#' at <- Sys.getenv("WASTDR_API_DEV_TOKEN")
#' x <- odkc_tt_as_wastd_nesttagobs(odkc_data$tt)
#' x %>% wastdr::wastd_POST("nest-tag-observations", api_url = au, api_token = at)
#' }
odkc_tt_as_wastd_nesttagobs <- function(data) {
  data %>%
    wastdr::sf_as_tbl() %>%
    dplyr::transmute(
      source = 2,
      source_id = id,
      encounter_source="odk",
      encounter_source_id = id,
      status = "applied-new",
      flipper_tag_id = ft1_ft1_name,
      tag_label = nest_nest_tag_label,
      date_nest_laid = nest_nest_tag_date %>%
        lubridate::format_ISO8601(precision = "ymd"),
      comments = nest_nest_tag_comments
    ) %>%
    dplyr::filter_at(
      dplyr::vars(-source, -source_id, -encounter_source, -encounter_source_id),
      dplyr::any_vars(!is.na(.))
    )
}

# usethis::use_test("odkc_tt_as_wastd_nesttagobs")
