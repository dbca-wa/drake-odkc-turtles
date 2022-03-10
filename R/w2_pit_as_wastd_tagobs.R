#' Transform w2_data into WAStD TagObservations.
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
#'
#' }
w2_pit_as_wastd_tagobs <- function(data) {
  tag_sides <- tibble::tribble(
    ~tag_location, ~tag_position,
    "shoulder-left", "LF",
    "shoulder-right", "RF",
    "other", "Other",
    "other", NA
  )

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
    magrittr::extract2("obs_pit_tags") %>%
    # wastdr::sf_as_tbl() %>%
    dplyr::filter(!(pit_tag_state %in% c("A2", "PX", "0", "#", "Q", "M", "M1", "N", "0L", "NA"))) %>%
    dplyr::transmute(
      # https://github.com/dbca-wa/wastd/blob/master/shared/models.py#L259
      source = 20,
      source_id = as.character(recorded_pit_tag_id),
      encounter_source = "wamtram",
      encounter_source_id = as.character(observation_id),
      tag_type = "pit-tag",
      tag_position = pit_tag_position,
      tag_state = pit_tag_state,
      name = as.character(pit_tag_id), # TODO sanitize
      comments = glue::glue("Tag status: {pit_tag_state}")
    ) %>%
    dplyr::left_join(tag_sides, by = "tag_position") %>%
    dplyr::left_join(tag_states, by = "tag_state") %>%
    dplyr::select(-tag_position, -tag_state) %>%
    dplyr::filter_at(
      dplyr::vars(-source, -source_id, -encounter_source, -encounter_source_id),
      dplyr::any_vars(!is.na(.))
    )
}


# use_test("w2_tag_as_wastd_tagobs")  # nolint
