#' Transform odkc_data$mwi_tag into WAStD TagObservations.
#'
#'
#' @seealso https://github.com/dbca-wa/wastd/blob/master/wastd/observations/utils.py#L1849
#' @param data Data of class `wamtram_data`.
#' @param user_mapping The output of `make_user_mapping_w2()`.
#' @return A tibble suitable to
#'   \code{\link{wastd_POST}("tag-observations")}
#' @export
#' @examples
#' \dontrun{
#' data("odkc_data", package = "wastdr")
#' au <- Sys.getenv("WASTDR_API_DEV_URL")
#' at <- Sys.getenv("WASTDR_API_DEV_TOKEN")
#' user_mapping <- NULL # see odkc_plan for actual user mapping
#' x <- odkc_mwi_tag_as_wastd_tagobs(odkc_ex$mwi_tag, user_mapping)
#' x %>% wastd_POST("tag-observations", api_url = au, api_token = at)
#' }
w2_tag_as_wastd_tagobs <- function(data, user_mapping) {
  wastd_handlers <- user_mapping %>%
    dplyr::transmute(tagger_person_id = legacy_userid, handler_id = pk)

  enc <- data %>%
    magrittr::extract2("enc") %>%
    dplyr::mutate(observation_id = as.character(observation_id))

  w2_handlers <- enc %>%
    dplyr::select(observation_id, tagger_person_id) %>%
    dplyr::left_join(wastd_handlers, by = "tagger_person_id") %>%
    tidyr::replace_na(list(handler_id = 1))

  wastd_recorders <- user_mapping %>%
    dplyr::transmute(reporter_person_id = legacy_userid, recorder_id = pk)

  w2_recorders <- enc %>%
    dplyr::select(observation_id, reporter_person_id) %>%
    dplyr::left_join(wastd_recorders, by = "reporter_person_id") %>%
    tidyr::replace_na(list(recorder_id = 1))


  tag_sides <- tibble::tribble(
    ~tag_location, ~attached_on_side, ~tag_position,
    "flipper-front-left-1", "L", 1,
    "flipper-front-left-2", "L", 2,
    "flipper-front-left-3", "L", 3,
    "flipper-front-left", "L", NA,
    "flipper-front-right-1", "R", 1,
    "flipper-front-right-2", "R", 2,
    "flipper-front-right-3", "R", 3,
    "flipper-front-right", "R", NA
  )

  #   unique(w2_data$obs_flipper_tags$tag_state)
  #  "A1"   "P"    "#"    "Q"    "P_OK" "N"    "R"    "PX"   "M"    "P_ED" NA
  #  "RQ"   "A2"   "AE"   "OO"   "RC"   "M1"
  #  "OX"   "ae"   "p"    "0L"

  # TAG_STATUS_CHOICES = (                                          # TRT_TAG_STATES
  #   ('ordered', 'ordered from manufacturer'),
  #   ('produced', 'produced by manufacturer'),
  #   ('delivered', 'delivered to HQ'),
  #   ('allocated', 'allocated to field team'),
  #   (TAG_STATUS_APPLIED_NEW, 'applied new'),                    # A1, AE
  #   (TAG_STATUS_DEFAULT, 're-sighted associated with animal'),  # OX, P, P_OK, RQ, P_ED
  #   ('reclinched', 're-sighted and reclinched on animal'),      # RC
  #   ('removed', 'taken off animal'),                            # OO, R
  #   ('found', 'found detached'),
  #   ('returned', 'returned to HQ'),
  #   ('decommissioned', 'decommissioned'),
  #   ('destroyed', 'destroyed'),
  #   ('observed', 'observed in any other context, see comments'), )

  tag_states <- tibble::tribble(
    ~tag_state, ~status,
    "A1", "applied-new",
    "AE", "applied-new",
    "ae", "applied-new",
    "OX", "resighted",
    "P", "resighted",
    "p", "resighted",
    "P_OK", "resighted",
    "RQ", "resighted",
    "P_ED", "resighted",
    "R", "removed",
    "OO", "removed",
    "RC", "reclinched"
  )



  data %>%
    magrittr::extract2("obs_flipper_tags") %>%
    # wastdr::sf_as_tbl() %>%
    dplyr::filter(!(tag_state %in% c("A2", "PX", "0", "#", "Q", "M", "M1", "N", "0L", "NA"))) %>%
    dplyr::transmute(
      # https://github.com/dbca-wa/wastd/blob/master/shared/models.py#L259
      source = 20,
      source_id = as.character(recorded_tag_id),
      encounter_source = "wamtram",
      encounter_source_id = observation_id %>% as.character(),
      # handler = reporter,
      # recorder = reporter,
      # handler_id = 1, # TODO enc.observer_id
      # reporter_id = 1, # TODO enc.reporter_id
      tag_type = "flipper-tag",
      attached_on_side = attached_on_side,
      tag_position = tag_position,
      tag_state = tag_state,
      name = tag_name, # TODO sanitize
      comments = glue::glue("Tag status: {tag_state}")
    ) %>%
    dplyr::left_join(w2_handlers, by = c("encounter_source_id" = "observation_id")) %>%
    dplyr::left_join(w2_recorders, by = c("encounter_source_id" = "observation_id")) %>%
    dplyr::left_join(tag_sides, by = c("attached_on_side", "tag_position")) %>%
    dplyr::left_join(tag_states, by = "tag_state") %>%
    dplyr::select(
      -tagger_person_id, -reporter_person_id,
      -attached_on_side, -tag_position, -tag_state
    ) %>%
    # If data == tracks or mwi, drop all NA subgroups
    # If data == tracks_*, there are only non-NA records
    dplyr::filter_at(
      dplyr::vars(-source, -source_id, -encounter_source, -encounter_source_id),
      dplyr::any_vars(!is.na(.))
    )
}


# use_test("w2_tag_as_wastd_tagobs")  # nolint
