#' Transform odkc_data$tt into WAStD AnimalEncounters.
#'
#' @param data An object of class "odkc_turtledata".
#' @template param-usermapping
#' @param tz A timezone, default: `ruODK::get_default_tz()`.
#' @return A tibble suitable to \code{\link{wastd_POST}("animal-encounters")}
#' @export
#' @examples
#' \dontrun{
#' data("odkc_data", package = "wastdr")
#' data("wastd_data", package = "wastdr")
#' au <- Sys.getenv("WASTDR_API_DEV_URL")
#' at <- Sys.getenv("WASTDR_API_DEV_TOKEN")
#' drake::loadd("user_mapping")
#' ae <- odkc_tt_as_wastd_ae(odkc_data, user_mapping)
#' ae %>% wastdr::wastd_POST("animal-encounters", api_url = au, api_token = at)
#' }
odkc_tt_as_wastd_ae <- function(data,
                                user_mapping,
                                tz = ruODK::get_default_tz()) {
  # Error handling
  if (is.null(data)) {
    wastdr::wastdr_msg_warn("[odkc_tt_as_wastd_ae] Data is NULL")
    return(NULL)
  }
  if (class(data) != "odkc_turtledata") {
    wastdr::wastdr_msg_warn("[odkc_tt_as_wastd_ae] Data must be odkc_turtledata")
    return(NULL)
  }
  if (!("tt" %in% names(data))) {
    wastdr::wastdr_msg_warn("[odkc_tt_as_wastd_ae] Data must be odkc_turtledata")
    return(NULL)
  }

  # User mapping
  wastd_reporters <- user_mapping %>%
    dplyr::transmute(reporter = odkc_username, reporter_id = pk)

  wastd_observers <- user_mapping %>%
    dplyr::transmute(observer = odkc_username, observer_id = pk)

  # Transform data
  data$tt %>%
    wastdr::sf_as_tbl() %>%
    dplyr::transmute(
      source = "odk",
      # wastd.observations.models.SOURCE_CHOICES
      source_id = id,
      observer = reporter,
      reporter = reporter,
      behaviour = glue::glue(
        "Form {meta_instance_name} filled in from {observation_start_time} to ",
        "{observation_end_time} in capture mode '{encounter_capture_mode}'.\n",
        "Record submitted on {system_submission_date} ",
        "by {system_submitter_name} from device {device_id}.\n",
        "Record initiated at {start_geopoint_latitude} ",
        "{start_geopoint_longitude}.\n",
        "Photos expected: {system_attachments_expected}, ",
        "present: {system_attachments_present}.\n",
        "Injuries: {turtle_damage_seen}, ",
        "Nesting success: {wastdr::humanize(nest_observed_nesting_success)}.\n",
        "Nesting disturbed: {nest_nesting_disturbed}, ",
        "cause {nest_nesting_disturbance_cause}.\n",
        "Eggs: {nest_eggs_counted}, {nest_egg_count}.\n",
        # nest_more_tags
        # nest_more_loggers
        "Datasheet comments: {datasheet_datasheet_comments}"
      ),
      when = dplyr::case_when(
        !is.na(manual_time) ~ lubridate::format_ISO8601(manual_time, usetz = TRUE),
        TRUE ~ lubridate::format_ISO8601(observation_start_time, usetz = TRUE)
      ),
      where = dplyr::case_when(
        # Manually backfilled coordinates using coordinate fields
        (encounter_capture_mode == "new" &
           !is.na(manual_nest_location_lat) &
           !is.na(manual_nest_location_lon)
         ) ~ glue::glue(
          "POINT ({manual_nest_location_lon} ",
          "{manual_nest_location_lat})"
         ),

        # Manually backfilled coordinates using map widget
        (encounter_capture_mode == "new" &
           # If manual_nest_location_lat/lon given, previous clause catches
           # is.na(manual_nest_location_lat) &
           # is.na(manual_nest_location_lon) &
           !is.na(manual_nest_location_map_latitude) &
           !is.na(manual_nest_location_map_longitude)
         ) ~ glue::glue(
             "POINT ({manual_nest_location_map_longitude} ",
             "{manual_nest_location_map_latitude})"
         ),

        # Geolocation captured in ODK
        encounter_capture_mode != "new" ~ glue::glue(
          "POINT ({realtime_nest_location_longitude} ",
          "{realtime_nest_location_latitude})"
        ),

        # Fallback: start_geolocation from metadata
        TRUE ~ glue::glue(
          "POINT ({start_geopoint_longitude} {start_geopoint_latitude})"
        )
      ),
      location_accuracy = "10",
      location_accuracy_m = dplyr::case_when(
        !is.na(realtime_nest_location_accuracy) ~ as.numeric(realtime_nest_location_accuracy),
        !is.na(manual_nest_location_map_accuracy) ~ as.numeric(manual_nest_location_map_accuracy),
        TRUE ~ as.numeric(start_geopoint_accuracy)
      ),
      taxon = "Cheloniidae",
      species = turtle_species %>% tidyr::replace_na("na"),
      sex = turtle_sex %>% tidyr::replace_na("na"),
      health = "alive",
      maturity = turtle_maturity %>% tidyr::replace_na("na"),
      # habitat = nest_habitat,
      activity = "general-breeding-activity", # models.NESTING_ACTIVITY_CHOICES
      nesting_event = nest_observed_nesting_success, # nesting success
      nesting_disturbed = nest_nesting_disturbed,
      scanned_for_pit_tags = ifelse(
        is.null(pit_pit_left_name),
        "present",
        "absent"
      ),
      checked_for_flipper_tags = ifelse(
        is.null(ft1_ft1_name),
        "present",
        "absent"
      ),
      checked_for_injuries = turtle_damage_seen
    ) %>%
    dplyr::left_join(wastd_reporters, by = "reporter") %>% # wastd User PK
    dplyr::left_join(wastd_observers, by = "observer") %>% # wastd User PK
    dplyr::select(-reporter, -observer) %>%
    invisible()
}

# usethis::use_test("odkc_tt_as_wastd_ae")
