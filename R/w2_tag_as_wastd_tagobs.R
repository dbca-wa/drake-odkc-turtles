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
    dplyr::transmute(handler = legacy_username, handler_id = pk)

  wastd_recorders <- user_mapping %>%
    dplyr::transmute(recorder = legacy_username, recorder_id = pk)


#
#   tag_name = sanitize_tag_label(t["tag_name"])
#   enc = AnimalEncounter.objects.get(
#     source_id=make_wamtram_source_id(t["observation_id"]))
#
#   new_data = dict(
#     encounter_id=enc.id,
#     tag_type='flipper-tag',
#     handler_id=enc.observer_id,
#     recorder_id=enc.reporter_id,
#     name=tag_name,
#     tag_location=make_tag_side(t["attached_on_side"], t["tag_position"]),
#     status=m["tag_status"][t["tag_state"]],
#     comments='{0}\nLTag label: {1}\nOriginal status: {2}'.format(
#       t["comments"], t["tag_label"], t["tag_state"]),
#   )


  # {
  #   'observation_id': '267425',
  #   'recorded_tag_id': '394783',
  #   'tag_name': 'WB 9239',
  #   'tag_state': 'A1',
  #   'attached_on_side': 'R',
  #   'tag_position': 'NA',
  #   'comments': 'NA',
  #   'tag_label': 'NA',
  #   }
  data %>%
    wastdr::sf_as_tbl() %>%
    # filter:
    #   if t["tag_state"] in ["A2", "PX", "0", "#", "Q", "M", "M1", "N", "0L", "NA"]:
    #     logger.info("Skipping tag obs with status {0}".format(t["tag_state"]))
    #   return None
    dplyr::transmute(
      # https://github.com/dbca-wa/wastd/blob/master/shared/models.py#L259
      source = 20,
      source_id = recorded_tag_id,
      encounter_source="wamtram",
      encounter_source_id = observation_id,
      handler = reporter, # TODO
      recorder = reporter, # TODO
      tag_type = 'flipper-tag',
      name = tag_name,
      tag_location = tag_location, # make_tag_side(t["attached_on_side"], t["tag_position"]),
      status = tag_status, # m["tag_status"][t["tag_state"]],
      comments = tag_comments # '{0}\nLTag label: {1}\nOriginal status: {2}'.format(t["comments"], t["tag_label"], t["tag_state"]),
    ) %>%
    dplyr::left_join(wastd_handlers, by = "handler") %>% # wastd User PK
    dplyr::left_join(wastd_recorders, by = "recorder") %>% # wastd User PK
    dplyr::select(-handler, -recorder) %>% # drop odkc_username
    # If data == tracks or mwi, drop all NA subgroups
    # If data == tracks_*, there are only non-NA records
    dplyr::filter_at(
      dplyr::vars(-source, -source_id, -encounter_source, -encounter_source_id),
      dplyr::any_vars(!is.na(.))
    )
}


# use_test("w2_tag_as_wastd_tagobs")  # nolint
