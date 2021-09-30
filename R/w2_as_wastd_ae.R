#' Transform W2 data into WAStD AnimalEncounters
#'
#' @param data Data of class `wamtram_data`.
#' @param user_mapping The output of `make_user_mapping_w2()`.
#' @template param-verbose
#' @return A tibble suitable to upload to the WAStD AnimalEncounters API endpoint.
#' @family wamtram
#' @export
w2_as_wastd_ae <- function(data,
                           user_mapping,
                           verbose = wastdr::get_wastdr_verbose()){
  # Error handling
  if (is.null(data)) {
    wastdr::wastdr_msg_warn("[w2_as_wastd_ae] Data is NULL", verbose = verbose)
    return(NULL)
  }
  if (class(data) != "wamtram_data") {
    wastdr::wastdr_msg_warn("[w2_as_wastd_ae] Data must be wamtram_data", verbose = verbose)
    return(NULL)
  }
  if (!("enc" %in% names(data))) {
    wastdr::wastdr_msg_warn("[w2_as_wastd_ae] Data must be wamtram_data", verbose = verbose)
    return(NULL)
  }
  if (is.null(user_mapping)) {
    wastdr::wastdr_msg_warn("[w2_as_wastd_ae] User mapping is NULL", verbose = verbose)
    return(NULL)
  }

  # User mapping
  wastd_reporters <- user_mapping %>%
    dplyr::transmute(reporter = legacy_userid, reporter_id = pk)

  wastd_observers <- user_mapping %>%
    dplyr::transmute(observer = legacy_userid, observer_id = pk)

  species_lookup <- tibble::tribble(
    ~ species_code, ~ species,
    "HK", "eretmochelys-imbricata",
    "FB", "natator-depressus",
    "LB", "dermochelys-coriacea",
    "GN", "chelonia-mydas"
  )

  # unique(w2_data$enc$beach_position_code)
  # "?" NA  "E" "D" "C" "A" "B"
  habitat_lookup <-
    tibble::tribble(
      ~ beach_position_code, ~ habitat,
      "A", "beach-above-high-water",
      "B", "beach-above-high-water",
      "C", "beach-below-high-water",
      "D", "beach-edge-of-vegetation",
      "E", "in-dune-vegetation",
      "?", "na"
    )

  # unique(w2_data$enc$activity_code)
  # [1] "H" "I" "F" "Q" "E" "G" "R" "X" "L" "S" "P" "A" "M" "C" "D" NA  "W" "K" "O" "B" "N" "Z" "&" "Y" "V"
  activity_lookup <-
    tibble::tribble(
      ~ activity_code, ~ activity,
      "&", "captivity",       # Captive animal
      "A", "arriving",        # Resting at waters edge - Nesting
      "B", "arriving",        # Leaving water - Nesting
      "C", "approaching",     # Climbing beach slope - Nesting
      "D", "approaching",     # Moving over bare sand (=beach) - Nesting
      "E", "digging-body-pit",  # Digging body hole - Nesting
      "F", "excavating-egg-chamber",  # Excavating egg chamber - Nesting
      "G", "laying-eggs",     # Laying eggs - confirmed observation - Nesting
      "H", "filling-in-egg-chamber",  # Covering nest (filling in) - Nesting
      "I", "returning-to-water",  # Returning to water - Nesting
      # "J", "",                # Check/?edit these: only on VA records
      "K", "non-breeding",    # Basking - on beach above waterline
      "L", "arriving",        # Arriving - Nesting
      "M", "other",           # Mating
      "N", "other",           # Courting
      "O", "non-breeding",    # Free at sea
      "Q", "na",              # Not recorded in field
      "R", "non-breeding",    # Released to wild
      "S", "non-breeding",    # Rescued from stranding
      "V", "non-breeding",    # Caught in fishing gear - Decd
      "W", "non-breeding",    # Captured in water (reef or sea)
      "X", "floating",        # Turtle dead
      "Y", "floating",        # Caught in fishing gear - Relsd
      "Z", "other",           # Hunted for food by Ab & others
      "NA", "na"
    )

  # TODO should this be clutch_completed?
  # unique(w2_data$enc$clutch_completed)
  # R> unique(w2_data$enc$activity_is_nesting)
  # [1] "Y" "U" "N" NA
  nesting_event_lookup <-
    tibble::tribble(
      ~ activity_is_nesting, ~ nesting_event,
      "Y", "present",
      "N", "absent",
      "U", "na"
    )

  # R> unique(w2_data$enc$condition_code)
  # [1] NA  "F" "D" "P" "G" "U" "H" "M"
  health_lookup <-
    tibble::tribble(
      ~ condition_code, ~ health,
      "F", "dead-edible",     # Carcase - fresh
      "G", "alive",           # Good - fat
      "H", "alive",           # Live & fit
      "I", "alive-injured",           # Injured but OK
      "M", "alive-injured",           # Moribund
      "P", "alive-injured",           # Poor - thin
      "NA", "na"
    )

  # R> unique(w2_data$enc$sex)
  # [1] "F" "I" "M"
  sex_lookup <-
    tibble::tribble(
      ~ sex_w2, ~ sex,
      "F", "female",
      "M", "male",
      "I", "na"
    )

  # checked_for_injuries = # TODO map did_not_check_for_injury"

  # Transform data
  data$enc %>%
    dplyr::filter(turtle_status != "E") %>%           # discard records in error
    dplyr::transmute(
      # wastd.observations.models.SOURCE_CHOICES
      source = "wamtram",
      source_id = observation_id,
      observer = tagger_person_id,
      reporter = reporter_person_id,
      behaviour = glue::glue(
        "Species ID confidence: {identification_confidence}\n",
        "Activity when encountered: {activity_label} {activity_description}\n",
        "Location: {location_code} {place_code} {label} {place_description}.",
        "Rookery: {is_rookery}, beach approach: {beach_approach}, beach aspect: {beach_aspect}\n"
        # # Left to map
        # original_observation_id
        # measurer_person_id > handler
        # measurer_reporter_person_id > recorder
        # nesting number_of_eggs egg_count_method > NestObs
        # measurements > morph
        # action_taken
        # comment_from recorded tags table
        #
        #   #
        # "turtle_id"
        # "scars_left" "scars_right" "other_tags" "other_tags_identification_type"
        # "transfer_id" "mund" "mund_id" "entered_by_person_id"
        #
        # "tag_scar_not_checked"
        # "scars_left_scale_1" "scars_left_scale_2" "scars_left_scale_3"
        # "scars_right_scale_1" "scars_right_scale_2" "scars_right_scale_3"
        #
        # "cc_length_not_measured" "cc_notch_length_not_measured" "cc_width_not_measured"
        #
        # # Health / Injuries / Mortality
        # "did_not_check_for_injury" "alive"
        #
        # "observation_status"
        # "display_this_observation" "label" "prefix"
        # "description"
        #
        # "" "" "turtle_status" ""
        # "cause_of_death" "re_entered_population"
        # "original_turtle_id"  "tag" "turtle_name"
      ),
      when = observation_datetime_utc,
      where = glue::glue("POINT ({longitude} {latitude})"),
      location_accuracy = "10",
      location_accuracy_m = 10,
      taxon = "Cheloniidae",
      maturity = "adult",
      # scanned_for_pit_tags = TODO,
      # checked_for_flipper_tags = TODO,
      # checked_for_injuries = # TODO map did_not_check_for_injury" "alive"
      #
      # Retain for left joins:
      species_code = species_code,
      beach_position_code = beach_position_code,
      activity_code = activity_code,
      activity_is_nesting = activity_is_nesting,
      sex_w2 = sex,
      condition_code = condition_code
    ) %>%
    dplyr::left_join(wastd_reporters, by = "reporter") %>% # wastd User PK
    dplyr::left_join(wastd_observers, by = "observer") %>% # wastd User PK
    dplyr::left_join(species_lookup, by="species_code") %>%
    dplyr::left_join(habitat_lookup, by="beach_position_code") %>%
    dplyr::left_join(activity_lookup, by="activity_code") %>%
    dplyr::left_join(nesting_event_lookup, by="activity_is_nesting") %>%
    dplyr::left_join(health_lookup, by="condition_code") %>%
    dplyr::left_join(sex_lookup, by="sex_w2") %>%
    # Discard joining cols:
    dplyr::select(-reporter,
                  -observer,
                  -species_code,
                  -beach_position_code,
                  -activity_code,
                  -activity_is_nesting,
                  -condition_code,
                  -sex_w2
    ) %>%
    invisible()
}

# use_test("w2_as_wastd_ae") # nolint
