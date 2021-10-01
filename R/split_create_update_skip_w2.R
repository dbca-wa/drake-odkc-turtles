#' Top level helper to split all WAMTRAM2 Turtle Tagging data per skip logic
#'
#' Encounters and their related observations are uploaded to WAStD:
#'
#' * New encounters will be created
#' * Existing but unchanged (status=new) encounters will be updated
#'   if `update_existing=TRUE`, else skipped.
#' * Existing and value-added encounters (status > new) will be skipped.
#'
#' @param w2_tf WAMTRAM data transformed into WAStD format.
#' @param wastd_data Minimal WAStD data to inform skip logic.
#' @return A list of results from the various uploads.
#'   Each result is a `wastd_api_response` or a tibble of data (`_skip`).
#' @export
split_create_update_skip_w2 <- function(w2_tf, wastd_data) {
  # WAStD Encounters are considered unchanged if QA status is "new" and
  # can be updated without losing edits applied in WAStD.
  enc_upd <- wastd_data$enc %>% dplyr::filter(source == "wamtram", status == "new")

  # WAStD Encounters are considered changed if QA status is not "new" and
  # should never be overwritten, as that would overwrite edits.
  enc_skp <- wastd_data$enc %>% dplyr::filter(source == "wamtram", status != "new")

  # svy_update <- wastd_data$surveys %>% dplyr::filter(status == "new")
  # svy_skip <- wastd_data$surveys %>% dplyr::filter(status != "new")

  enc_create <-
    . %>% dplyr::anti_join(wastd_data$enc, by = "source_id")
  enc_update <- . %>% dplyr::semi_join(enc_upd, by = "source_id")
  enc_skip <-   . %>% dplyr::semi_join(enc_skp, by = "source_id")

  obs_match <- c("encounter_source_id" = "source_id")
  obs_create <-
    . %>% dplyr::anti_join(wastd_data$enc, by = obs_match)
  obs_update <- . %>% dplyr::semi_join(enc_upd, by = obs_match)
  obs_skip <-   . %>% dplyr::semi_join(enc_skp, by = obs_match)

  res <- list(
    # Tagging > AE ------------------------------------------------------------#
    # AE
    tt_create = w2_tf$tt %>% enc_create(),
    tt_update = w2_tf$tt %>% enc_update(),
    tt_skip = w2_tf$tt %>% enc_skip()

    # # Obs
    # tt_dmg_create = w2_tf$tt_dmg %>% obs_create()
    # tt_dmg_update = w2_tf$tt_dmg %>% obs_update()
    # tt_dmg_skip = w2_tf$tt_dmg %>% obs_skip()
    # #
    # tt_tsc_create = w2_tf$tt_tsc %>% obs_create()
    # tt_tsc_update = w2_tf$tt_tsc %>% obs_update()
    # tt_tsc_skip = w2_tf$tt_tsc %>% obs_skip()
    #
    # tt_log_create = w2_tf$tt_log %>% obs_create()
    # tt_log_update = w2_tf$tt_log %>% obs_update()
    # tt_log_skip = w2_tf$tt_log %>% obs_skip()
    #
    # tt_mor_create = w2_tf$tt_mor %>% obs_create()
    # tt_mor_update = w2_tf$tt_mor %>% obs_update()
    # tt_mor_skip = w2_tf$tt_mor %>% obs_skip()
    #
    # tt_tag_create = w2_tf$tt_tag %>% obs_create()
    # tt_tag_update = w2_tf$tt_tag %>% obs_update()
    # tt_tag_skip = w2_tf$tt_tag %>% obs_skip()
    #
    # tt_tag_create = w2_tf$tt_tag %>% obs_create()
    # tt_tag_update = w2_tf$tt_tag %>% obs_update()
    # tt_tag_skip = w2_tf$tt_tag %>% obs_skip()
    #
    # tt_nto_create = w2_tf$tt_nto %>% obs_create()
    # tt_nto_update = w2_tf$tt_nto %>% obs_update()
    # tt_nto_skip = w2_tf$tt_nto %>% obs_skip()
    #
    # tt_tno_create = w2_tf$tt_tno %>% obs_create()
    # tt_tno_update = w2_tf$tt_tno %>% obs_update()
    # tt_tno_skip = w2_tf$tt_tno %>% obs_skip()
  )
  res
}
