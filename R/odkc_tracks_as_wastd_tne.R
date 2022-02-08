#' Transform odkc_data$tracks into WAStD TurtleNestEncounters.
#'
#' @param data A tibble of parsed ODKC Track or Nests,
#'   e.g. \code{odkc_data$tracks}.
#' @param user_mapping .
#' @return A tibble suitable to
#'   \code{\link{wastd_POST}("turtle-nest-encounters")}
#' @export
#' @examples
#' \dontrun{
#' data("odkc_data", package = "wastdr")
#' user_mapping <- NULL # see odkc_plan for actual user mapping
#'
#' odkc_data$tracks %>%
#'   odkc_tracks_as_wastd_tne(user_mapping) %>%
#'   head(1) %>%
#'   jsonlite::toJSON()
#'
#' tne <- odkc_data$tracks %>%
#'   odkc_tracks_as_wastd_tne(user_mapping) %>%
#'   dplyr::mutate(reporter_id = 4, observer_id = 4) %>% # missing users in local dev
#'   head()
#'
#' tne_update <- dplyr::anti_join(x, tsc_data$enc, by = "source_id")
#' tne_create <- dplyr::anti_join(tsc_data$enc, x, by = "source_id")
#'
#' tne_create %>%
#'   wastd_POST("turtle-nest-encounters",
#'     api_url = Sys.getenv("WASTDR_API_DEV_URL"),
#'     api_token = Sys.getenv("WASTDR_API_DEV_TOKEN")
#'   )
#' }
odkc_tracks_as_wastd_tne <- function(data, user_mapping) {
  wastd_reporters <- user_mapping %>%
    dplyr::transmute(reporter = odkc_username, reporter_id = pk)

  wastd_observers <- user_mapping %>%
    dplyr::transmute(observer = odkc_username, observer_id = pk)

  data %>%
    wastdr::sf_as_tbl() %>%
    dplyr::transmute(
      source = "odk", # wastd.observations.models.SOURCE_CHOICES
      source_id = id,
      observer = reporter %>%
        stringr::str_squish() %>%
        stringr::str_to_lower(),
      reporter = observer,
      comments = glue::glue("Device ID {device_id}"),
      where = glue::glue(
        "POINT ({details_observed_at_longitude}",
        " {details_observed_at_latitude})"
      ),
      location_accuracy = "10",
      location_accuracy_m = details_observed_at_accuracy,
      when = lubridate::format_ISO8601(observation_start_time, usetz = TRUE),
      nest_age = details_nest_age,
      nest_type = details_nest_type,
      species = details_species,
      habitat = nest_habitat %>% tidyr::replace_na("na"),
      disturbance = nest_disturbance %>% tidyr::replace_na("na"),
      nest_tagged = nest_nest_tagged %>% tx_obs_choices,
      logger_found = nest_logger_found %>% tx_obs_choices,
      eggs_counted = nest_eggs_counted %>% tx_obs_choices,
      hatchlings_measured = nest_hatchlings_measured %>% tx_obs_choices,
      fan_angles_measured = nest_fan_angles_measured %>% tx_obs_choices
    ) %>%
    dplyr::left_join(wastd_reporters, by = "reporter") %>% # WAStD User PK
    dplyr::left_join(wastd_observers, by = "observer") %>% # WAStD User PK
    dplyr::select(-reporter, -observer) # drop odkc_username
}


tx_obs_choices <- . %>% tidyr::replace_na("na") %>%
  stringr::str_replace_all("yes", "present") %>%
  stringr::str_replace_all("no", "absent")

# usethis::use_test("odkc_tracks_as_wastd_tne")
