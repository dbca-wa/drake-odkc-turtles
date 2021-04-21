#' Top level helper to split all Turtle Nesting Census data per skip logic
#'
#' Encounters and their related observations are uploaded to WAStD:
#'
#' * New encounters will be created
#' * Existing but unchanged (status=new) encounters will be updated
#'   if `update_existing=TRUE`, else skipped.
#' * Existing and value-added encounters (status > new) will be skipped.s
#'
#' @param odkc_prep ODKC data transformed into WAStD format.
#' @param wastd_data Minimal WAStD data to inform skip logic.
#' @return A list of results from the various uploads.
#'   Each result is a `wastd_api_response` or a tibble of data (`_skip`).
#' @export
split_create_update_skip <- function(odkc_prep, wastd_data) {
  # WAStD Encounters are considered unchanged if QA status is "new" and
  # can be updated without losing edits applied in WAStD.
  enc_upd <- wastd_data$enc %>% dplyr::filter(status == "new")

  # WAStD Encounters are considered changed if QA status is not "new" and
  # should never be overwritten, as that would overwrite edits.
  enc_skp <- wastd_data$enc %>% dplyr::filter(status != "new")

  svy_update <- wastd_data$surveys %>% dplyr::filter(status == "new")
  svy_skip <- wastd_data$surveys %>% dplyr::filter(status != "new")

  enc_create <- . %>% dplyr::anti_join(wastd_data$enc, by = "source_id")
  enc_update <- . %>% dplyr::semi_join(enc_upd, by = "source_id")
  enc_skip <-   . %>% dplyr::semi_join(enc_skp, by = "source_id")

  obs_match <- c("encounter_source_id" = "source_id")
  obs_create <- . %>% dplyr::anti_join(wastd_data$enc, by = obs_match)
  obs_update <- . %>% dplyr::semi_join(enc_upd, by = obs_match)
  obs_skip <-   . %>% dplyr::semi_join(enc_skp, by = obs_match)


  res <- list(
    # Tracks ------------------------------------------------------------------#
    tne_create = odkc_prep$tne %>% enc_create(),
    tne_update = odkc_prep$tne %>% enc_update(),
    tne_skip = odkc_prep$tne %>% enc_skip(),

    tn_dist_create = odkc_prep$tn_dist %>% obs_create(),
    tn_dist_update = odkc_prep$tn_dist %>% obs_update(),
    tn_dist_skip = odkc_prep$tn_dist %>% obs_skip(),

    tn_tags_create = odkc_prep$tn_tags %>% obs_create(),
    tn_tags_update = odkc_prep$tn_tags %>% obs_update(),
    tn_tags_skip = odkc_prep$tn_tags %>% obs_skip(),

    tn_eggs_create = odkc_prep$tn_eggs %>% obs_create(),
    tn_eggs_update = odkc_prep$tn_eggs %>% obs_update(),
    tn_eggs_skip = odkc_prep$tn_eggs %>% obs_skip(),

    th_morph_create = odkc_prep$th_morph %>% obs_create(),
    th_morph_update = odkc_prep$th_morph %>% obs_update(),
    th_morph_skip = odkc_prep$th_morph %>% obs_skip(),

    th_emerg_create = odkc_prep$th_emerg %>% obs_create(),
    th_emerg_update = odkc_prep$th_emerg %>% obs_update(),
    th_emerg_skip = odkc_prep$th_emerg %>% obs_skip(),

    th_outlier_create = odkc_prep$th_outlier %>% obs_create(),
    th_outlier_update = odkc_prep$th_outlier %>% obs_update(),
    th_outlier_skip = odkc_prep$th_outlier %>% obs_skip(),

    th_light_create = odkc_prep$th_light %>% obs_create(),
    th_light_update = odkc_prep$th_light %>% obs_update(),
    th_light_skip = odkc_prep$th_light %>% obs_skip(),

    # TrackTally Encounters ---------------------------------------------------#
    tte_create = odkc_prep$tte %>% enc_create(),
    tte_update = odkc_prep$tte %>% enc_update(),
    tte_skip = odkc_prep$tte %>% enc_skip(),

    # tto
    tto_create = odkc_prep$tto %>% obs_create(),
    tto_update = odkc_prep$tto %>% obs_update(),
    tto_skip = odkc_prep$tto %>% obs_skip(),

    # ttd
    ttd_create = odkc_prep$ttd %>% obs_create(),
    ttd_update = odkc_prep$ttd %>% obs_update(),
    ttd_skip = odkc_prep$ttd %>% obs_skip(),

    # Logger Encounters > Obs -------------------------------------------------#
    lo_create = odkc_prep$lo %>% obs_create(),
    lo_update = odkc_prep$lo %>% obs_update(),
    lo_skip = odkc_prep$lo %>% obs_skip(),

    # Disturbance Encounters --------------------------------------------------#
    de_mwi_create = odkc_prep$de %>% enc_create(),
    de_mwi_update = odkc_prep$de %>% enc_update(),
    de_mwi_skip = odkc_prep$de %>% enc_skip(),

    # Disturbance TND obs
    tnd_obs_create = odkc_prep$tnd_obs %>% obs_create(),
    tnd_obs_update = odkc_prep$tnd_obs %>% obs_update(),
    tnd_obs_skip = odkc_prep$tnd_obs %>% obs_skip(),


    # MWI > AE ----------------------------------------------------------------#
    ae_mwi_create = odkc_prep$ae_mwi %>% enc_create(),
    ae_mwi_update = odkc_prep$ae_mwi %>% enc_update(),
    ae_mwi_skip = odkc_prep$ae_mwi %>% enc_skip(),
    #
    # MWI > obs turtlemorph
    obs_turtlemorph_create = odkc_prep$obs_turtlemorph %>% obs_create(),
    obs_turtlemorph_update = odkc_prep$obs_turtlemorph %>% obs_update(),
    obs_turtlemorph_skip = odkc_prep$obs_turtlemorph %>% obs_skip(),
    #
    obs_tagobs_create = odkc_prep$obs_tagobs %>% obs_create(),
    obs_tagobs_update = odkc_prep$obs_tagobs %>% obs_update(),
    obs_tagobs_skip = odkc_prep$obs_tagobs %>% obs_skip(),
    #
    obs_turtledmg_create = odkc_prep$obs_turtledmg %>% obs_create(),
    obs_turtledmg_update = odkc_prep$obs_turtledmg %>% obs_update(),
    obs_turtledmg_skip = odkc_prep$obs_turtledmg %>% obs_skip(),

    # TSI > AE ----------------------------------------------------------------#
    ae_tsi_create = odkc_prep$ae_tsi %>% enc_create(),
    ae_tsi_update = odkc_prep$ae_tsi %>% enc_update(),
    ae_tsi_skip = odkc_prep$ae_tsi %>% enc_skip(),



    # Surveys -----------------------------------------------------------------#
    svy_create = odkc_prep$surveys %>%
      dplyr::anti_join(wastd_data$surveys, by = "source_id"),
    svy_update = odkc_prep$surveys %>%
      dplyr::semi_join(svy_update, by = "source_id"),
    svy_skip = odkc_prep$surveys %>%
      dplyr::semi_join(svy_skip, by = "source_id"),
    survey_media_create = odkc_prep$survey_media %>%
      dplyr::anti_join(wastd_data$survey_media, by = "source_id"),
    survey_media_skip = odkc_prep$media %>%
      dplyr::semi_join(wastd_data$survey_media, by = "source_id"),

    # Media
    media_create = odkc_prep$media %>%
      dplyr::anti_join(wastd_data$media, by = "source_id"),
    media_skip = odkc_prep$media %>%
      dplyr::semi_join(wastd_data$media, by = "source_id")
  )

  if ("tt" %in% names(odkc_prep)) {
    # Tagging > AE ------------------------------------------------------------#
    # AE
    res$tt_create = odkc_prep$tt %>% enc_create()
    res$tt_update = odkc_prep$tt %>% enc_update()
    res$tt_skip = odkc_prep$tt %>% enc_skip()

    # Obs
    res$tt_dmg_create = odkc_prep$tt_dmg %>% obs_create()
    res$tt_dmg_update = odkc_prep$tt_dmg %>% obs_update()
    res$tt_dmg_skip = odkc_prep$tt_dmg %>% obs_skip()
    #
    res$tt_tsc_create = odkc_prep$tt_tsc %>% obs_create()
    res$tt_tsc_update = odkc_prep$tt_tsc %>% obs_update()
    res$tt_tsc_skip = odkc_prep$tt_tsc %>% obs_skip()
    #
    res$tt_log_create = odkc_prep$tt_log %>% obs_create()
    res$tt_log_update = odkc_prep$tt_log %>% obs_update()
    res$tt_log_skip = odkc_prep$tt_log %>% obs_skip()
    #
    res$tt_mor_create = odkc_prep$tt_mor %>% obs_create()
    res$tt_mor_update = odkc_prep$tt_mor %>% obs_update()
    res$tt_mor_skip = odkc_prep$tt_mor %>% obs_skip()
    #
    res$tt_tag_create = odkc_prep$tt_tag %>% obs_create()
    res$tt_tag_update = odkc_prep$tt_tag %>% obs_update()
    res$tt_tag_skip = odkc_prep$tt_tag %>% obs_skip()
    #
    res$tt_tag_create = odkc_prep$tt_tag %>% obs_create()
    res$tt_tag_update = odkc_prep$tt_tag %>% obs_update()
    res$tt_tag_skip = odkc_prep$tt_tag %>% obs_skip()
    #
    res$tt_nto_create = odkc_prep$tt_nto %>% obs_create()
    res$tt_nto_update = odkc_prep$tt_nto %>% obs_update()
    res$tt_nto_skip = odkc_prep$tt_nto %>% obs_skip()
    #
    res$tt_tno_create = odkc_prep$tt_tno %>% obs_create()
    res$tt_tno_update = odkc_prep$tt_tno %>% obs_update()
    res$tt_tno_skip = odkc_prep$tt_tno %>% obs_skip()
  }
  res
}
