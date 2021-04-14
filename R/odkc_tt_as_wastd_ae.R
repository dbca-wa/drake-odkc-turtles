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

  # [21] "encounter_handler"                           "realtime_nest_location_longitude"
  # [23] "realtime_nest_location_latitude"             "realtime_nest_location_altitude"
  # [25] "realtime_nest_location_accuracy"             "realtime_nest_location"
  # [27] "realtime_start_time_repeat"
  #
  # TagObs:
  # "pit_pit1_status"
  # [29] "pit_pit2_status"
  # "pit_pit3_status"
  # [31] "pit_pit3_location"
  # "pit_pit_left_name"
  # "pit_pit2_name"
  #
  # "ft1_ft1_name"
  # [35] "ft1_ft1_status"                              "ft1_ft1_location"
  # [37] "ft1_tag_1_barnacles"                         "ft1_tag_1_fix"
  # [39] "ft1_ft1_handled_by"                          "ft1_tag_scar_locations"
  # [41] "ft1_tag_sighted_but_unread"                  "ft1_ft1_comments"
  #
  # [43] "ft2_ft2_status"                              "ft2_ft2_location"
  # [45] "ft2_tag_2_barnacles"                         "ft2_tag_2_fix"
  # [47] "ft2_ft2_handled_by"                          "ft2_ft2_name"
  #
  # [49] "ft3_ft3_status"                              "ft3_tag_3_barnacles"
  # [51] "ft3_tag_3_fix"                               "ft3_ft3_handled_by"
  #
  # [53] "biopsy_biopsy_location"
  # "biopsy_biopsy_name"
  # [55] "biopsy_biopsy_comments"
  #
  #
  # TurtleMorphObs
  # [57] "morphometrics_curved_carapace_length_min_mm"
  # "morphometrics_curved_carapace_width_mm"
  # [59] "morphometrics_weight"
  # "morphometrics_morphometrics_handled_by"
  #
  # NestTagObs
  # [67] "nest_nest_tag_date"
  # [73] "nest_nest_tag_label"
  #
  # NestObs
  # nest_eggs_counted nest_egg_count nest_egg_count_accuracy
  #
  # Media
  # "datasheet_photo_datasheet_front"
  # [77] "datasheet_photo_datasheet_rear"

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
        "Record initiated at {start_location_latitude} ",
        "{start_location_longitude}.\n",
        "Photos expected: {system_attachments_expected}, ",
        "present: {system_attachments_present}.\n",
        "Nesting success: {wastdr::humanize(nest_observed_nesting_success)}.\n",
        "Nesting disturbed: {nest_nesting_disturbed}, ",
        "cause {nest_nesting_disturbance_cause}.\n",
        "Eggs {nest_egg_count_accuracy}: {nest_eggs_counted}, {nest_egg_count}.\n",
        # nest_more_tags
        # nest_more_loggers
        "Datasheet comments: {datasheet_datasheet_comments}"
      ),
      # manually backfilled:
      # manual_nest_location_lat           (if handheld GPS used)
      # manual_nest_location_lon
      # manual_nest_location_map_longitude (if offline map used)
      # manual_nest_location_map_latitude
      # manual_nest_location_time
      when = lubridate::format_ISO8601(observation_start_time, usetz = TRUE),
      where = glue::glue(
        "POINT ({realtime_nest_location_longitude} ",
        "{realtime_nest_location_latitude})"
      ),
      location_accuracy = "10",
      location_accuracy_m = start_location_accuracy,
      taxon = "Cheloniidae",
      species = nest_species %>% tidyr::replace_na("na"),
      sex = nest_sex %>% tidyr::replace_na("na"),
      health = "alive",
      maturity = "adult", # in-water rodeo catch tagging could be subadult
      habitat = nest_habitat,
      activity = "general-breeding-activity", # models.NESTING_ACTIVITY_CHOICES
      nesting_event = "present",
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
      checked_for_injuries = nest_damage_seen
    ) %>%
    dplyr::left_join(wastd_reporters, by = "reporter") %>% # wastd User PK
    dplyr::left_join(wastd_observers, by = "observer") %>% # wastd User PK
    dplyr::select(-reporter, -observer) %>%
    invisible()
}

# usethis::use_test("odkc_tt_as_wastd_ae")
