#' Transform odkc_data$tt into WAStD TurtleMorphometricObservations.
#'
#' @param data A tibble of Turtle Tagging records, e.g. \code{odkc_data$tt}.
#' @param user_mapping .
#' @return A tibble suitable to
#'   \code{\link{wastd_POST}("turtle-morphometrics")}
#' @export
#' @examples
#' \dontrun{
#' data("odkc_data", package = "wastdr")
#' data("wastd_data", package = "wastdr")
#' au <- Sys.getenv("WASTDR_API_DEV_URL")
#' at <- Sys.getenv("WASTDR_API_DEV_TOKEN")
#' drake::loadd("user_mapping")
#' tmorph <- odkc_tt_as_wastd_turtlemorph(odkc_data$tt, user_mapping)
#'
#' res <- tmorph %>%
#'   wastdr::wastd_POST("turtle-morphometrics", api_url = au, api_token = at)
#' }
odkc_tt_as_wastd_turtlemorph <- function(data, user_mapping) {
  wastd_handlers <- user_mapping %>%
    dplyr::transmute(handler = odkc_username, handler_id = pk)

  wastd_recorders <- user_mapping %>%
    dplyr::transmute(recorder = odkc_username, recorder_id = pk)

  data %>%
    wastdr::sf_as_tbl() %>%
    dplyr::transmute(
      source = 2,
      source_id = id,
      encounter_source = "odk",
      encounter_source_id = id,
      handler = morphometrics_morphometrics_handled_by,
      recorder = reporter,
      # WAStD TurtleMorphometrics has more fields, but TT only captures:
      curved_carapace_length_min_mm = morphometrics_curved_carapace_length_min_mm,
      curved_carapace_length_mm = morphometrics_curved_carapace_length_max_mm,
      curved_carapace_width_mm = morphometrics_curved_carapace_width_mm,
      body_weight_g = morphometrics_weight * 1000, # kg to g
      maximum_head_width_mm = morphometrics_maximum_head_width_mm,
      tail_length_carapace_mm = morphometrics_tail_length_carapace_mm,
      tail_length_plastron_mm = morphometrics_tail_length_plastron_mm,
      tail_length_vent_mm = morphometrics_tail_length_vent_mm
    ) %>%
    dplyr::left_join(wastd_handlers, by = "handler") %>% # wastd User PK
    dplyr::left_join(wastd_recorders, by = "recorder") %>% # wastd User PK
    dplyr::select(-handler, -recorder) %>% # drop odkc_username
    dplyr::filter_at(
      dplyr::vars(-source, -source_id, -encounter_source, -encounter_source_id),
      dplyr::any_vars(!is.na(.))
    )
}

# usethis::use_test("odkc_tt_as_wastd_turtlemorph")
