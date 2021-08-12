w2_as_wastd_ae <- function(data, user_mapping){
  # Error handling
  if (is.null(data)) {
    wastdr::wastdr_msg_warn("[w2_as_wastd_ae] Data is NULL")
    return(NULL)
  }
  if (class(data) != "wamtram_data") {
    wastdr::wastdr_msg_warn("[w2_as_wastd_ae] Data must be wamtram_data")
    return(NULL)
  }
  if (!("enc" %in% names(data))) {
    wastdr::wastdr_msg_warn("[w2_as_wastd_ae] Data must be wamtram_data")
    return(NULL)
  }

  # User mapping
  wastd_reporters <- user_mapping %>%
    dplyr::transmute(reporter = legacy_userid, reporter_id = pk)

  wastd_observers <- user_mapping %>%
    dplyr::transmute(observer = legacy_userid, observer_id = pk)

  # # Mapped
  # observation_id
  # tagger_person_id
  # reporter_person_id
  # latitude
  # longitude
  # observation_datetime_utc
  # activity_code
  # beach_position_code
  # condition_code
  # clutch_completed
  #
  # # Duplicated
  # comments.x entered_by.x date_entered.x entry_batch_id.x
  #
  # # Left to map
  # original_observation_id
  # measurer_person_id > handler
  # measurer_reporter_person_id> recorder
  # nesting number_of_eggs egg_count_method > NestObs
  # measurements > morph
  # action_taken
  # comment_fromrecordedtagstable
  #
  # # Time
  # date_convention observation_datetime_gmt08
  #
  # # Location
  # datum_code
  # latitude_degrees latitude_minutes latitude_seconds
  # longitude_degrees longitude_minutes longitude_seconds
  # zone easting northing
  #
  # # Site
  # place_code place_description
  #
  # "turtle_id"                      "alive"
  # [37] "scars_left"                     "scars_right"                    "other_tags"                     "other_tags_identification_type"
  # [41] "transfer_id"                    "mund"                           "entered_by_person_id"           "scars_left_scale_1"
  # [45] "scars_left_scale_2"             "scars_left_scale_3"             "scars_right_scale_1"            "scars_right_scale_2"
  # [49] "scars_right_scale_3"            "cc_length_not_measured"         "cc_notch_length_not_measured"   "cc_width_not_measured"
  # [53] "tag_scar_not_checked"           "did_not_check_for_injury"
  # ""                "observation_status"
  # [57]       "activity_description"           "activity_is_nesting"
  # [61] "activity_label"                 "display_this_observation"       "label"                          "prefix"
  # [65] "is_rookery"                     "beach_approach"                 "beach_aspect"                   "site_datum"
  # [69] "site_latitude"                  "site_longitude"                 "description"                    "species_code"
  # [73] "identification_confidence"      "sex"                            "turtle_status"                  "location_code"
  # [77] "cause_of_death"                 "re_entered_population"          "comments.y"                     "entered_by.y"
  # [81] "date_entered.y"                 "original_turtle_id"             "entry_batch_id.y"               "tag"
  # [85] "mund_id"                        "turtle_name"

  # Transform data
  data$enc %>%
    dplyr::transmute(
      # wastd.observations.models.SOURCE_CHOICES
      source = "wamtram",
      source_id = observation_id,
      observer = tagger_person_id,
      reporter = reporter_person_id,
      behaviour = glue::glue(
        ""
      ),
      when = observation_datetime_utc,
      where = glue::glue("POINT ({longitude} {latitude})"),
      location_accuracy = "10",
      location_accuracy_m = 10,
      taxon = "Cheloniidae",
      species = species_code, # TODO join lookup FB > natator-depressus
      sex = sex, # TODO map F > female
      health = "alive", # TODO map condition_code
      maturity = "adult",
      habitat = nest_habitat, # TOD map beach_position_code
      activity = "general-breeding-activity", # TODO map activity_code > models.NESTING_ACTIVITY_CHOICES
      nesting_event = "present", # TODO map clutch_completed to present/absent/na
      # scanned_for_pit_tags = TODO,
      # checked_for_flipper_tags = TODO,
      # checked_for_injuries = nest_damage_seen
    ) %>%
    dplyr::left_join(wastd_reporters, by = "reporter") %>% # wastd User PK
    dplyr::left_join(wastd_observers, by = "observer") %>% # wastd User PK
    dplyr::select(-reporter, -observer) %>%
    invisible()
}
