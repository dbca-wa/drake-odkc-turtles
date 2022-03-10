#' Transform odkc_data into WAStD TagObservations.
#'
#' @param data An object of class odkc_data, e.g. \code{odkc_data}.
#' @template param-usermapping
#' @return A tibble suitable to \code{\link{wastd_POST}("tag-observations")}.
#' @export
#' @examples
#' \dontrun{
#' data("odkc_data", package = "wastdr")
#' data("wastd_data", package = "wastdr")
#' au <- Sys.getenv("WASTDR_API_DEV_URL")
#' at <- Sys.getenv("WASTDR_API_DEV_TOKEN")
#' drake::loadd("user_mapping")
#' x <- odkc_tt_tag_as_wastd_tagobs(odkc_data, user_mapping)
#' x %>% wastdr::wastd_POST("tag-observations", api_url = au, api_token = at)
#' }
odkc_tt_tag_as_wastd_tagobs <- function(data, user_mapping) {
  wastd_handlers <- user_mapping %>%
    dplyr::transmute(handler = odkc_username, handler_id = pk)

  wastd_recorders <- user_mapping %>%
    dplyr::transmute(recorder = odkc_username, recorder_id = pk)

  d <- data$tt %>% wastdr::sf_as_tbl()

  pit1 <- d %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-pit1"),
      encounter_source = "odk",
      encounter_source_id = id,
      handler = reporter,
      recorder = reporter,
      tag_type = "pit-tag", # flipper-tag pit-tag sat-tag biopsy-sample
      name = pit_pit_left_name, # "pit_pit2_name"
      tag_location = "shoulder-left", # "pit_pit3_location"
      status = pit_pit1_status # "" "pit_pit2_status" "pit_pit3_status"
      # comments = tag_comments
    )

  pit2 <- d %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-pit2"),
      encounter_source = "odk",
      encounter_source_id = id,
      handler = reporter,
      recorder = reporter,
      tag_type = "pit-tag", # flipper-tag pit-tag sat-tag biopsy-sample
      name = pit_pit2_name, # "pit_pit2_name"
      tag_location = "shoulder-right", # "pit_pit3_location"
      status = pit_pit2_status # "" "" "pit_pit3_status"
      # comments = tag_comments
    )

  pit3 <- d %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-pit3"),
      encounter_source = "odk",
      encounter_source_id = id,
      handler = reporter,
      recorder = reporter,
      tag_type = "pit-tag", # flipper-tag pit-tag sat-tag biopsy-sample
      name = pit_pit3_name,
      tag_location = pit_pit3_location,
      status = pit_pit3_status
    )

  ft1 <- d %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-ft1"),
      encounter_source = "odk",
      encounter_source_id = id,
      handler = ft1_ft1_handled_by,
      recorder = reporter,
      tag_type = "flipper-tag", # pit-tag sat-tag biopsy-sample
      name = ft1_ft1_name,
      tag_location = ft1_ft1_location,
      status = ft1_ft1_status,
      comments = glue::glue(
        "Tag fix: {ft1_tag_1_fix}. ",
        "Barnacles: {ft1_tag_1_barnacles}. ",
        "Comments: {ft1_ft1_comments}"
      )
    )

  ft2 <- d %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-ft2"),
      encounter_source = "odk",
      encounter_source_id = id,
      handler = ft2_ft2_handled_by,
      recorder = reporter,
      tag_type = "flipper-tag", # pit-tag sat-tag biopsy-sample
      name = ft2_ft2_name,
      tag_location = ft2_ft2_location,
      status = ft2_ft2_status,
      comments = glue::glue(
        "Tag fix: {ft2_tag_2_fix}. ",
        "Barnacles: {ft2_tag_2_barnacles}. ",
        "Comments: {ft2_ft2_comments}"
      )
    )

  ft3 <- d %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-ft3"),
      encounter_source = "odk",
      encounter_source_id = id,
      handler = ft3_ft3_handled_by,
      recorder = reporter,
      tag_type = "flipper-tag", # pit-tag sat-tag biopsy-sample
      name = ft3_ft3_name,
      tag_location = ft3_ft3_location,
      status = ft2_ft2_status,
      comments = glue::glue(
        "Tag fix: {ft3_tag_3_fix}. ",
        "Barnacles: {ft3_tag_3_barnacles}. ",
        "Comments: {ft3_ft3_comments}"
      )
    )

  biopsy <- d %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-biopsy"),
      encounter_source = "odk",
      encounter_source_id = id,
      handler = reporter,
      recorder = reporter,
      tag_type = "biopsy-sample",
      name = biopsy_biopsy_name,
      tag_location = biopsy_biopsy_location,
      status = "removed",
      comments = biopsy_biopsy_comments
    )

  extra <- data$tt_tag %>%
    dplyr::transmute(
      source = 2,
      source_id = id,
      encounter_source = "odk",
      encounter_source_id = submissions_id,
      handler = tag_handled_by,
      recorder = tag_handled_by,
      tag_type = tag_type,
      name = tag_name,
      tag_location = tag_location,
      status = tag_status,
      comments = glue::glue(
        "Tag fix: {tag_fix}. ",
        "Barnacles: {tag_barnacles}. ",
        "Comments: {tag_comments}"
      )
    )


  # Return combined data
  dplyr::bind_rows(
    pit1,
    pit2,
    pit3,
    ft1,
    ft2,
    ft3,
    biopsy,
    extra
  ) %>%
    dplyr::left_join(wastd_handlers, by = "handler") %>% # wastd User PK
    dplyr::left_join(wastd_recorders, by = "recorder") %>% # wastd User PK
    dplyr::select(-handler, -recorder) %>% # drop odkc_username
    dplyr::filter_at(dplyr::vars(name), dplyr::any_vars(!is.na(.)))
}

# usethis::use_test("odkc_tt_tag_as_wastd_tagobs")
