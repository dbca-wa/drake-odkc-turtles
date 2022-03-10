#' Top level helper to upload all Turtle Nesting Census data to WAStD
#'
#' Encounters and their related observations are uploaded to WAStD:
#'
#' * New encounters will be created
#' * Existing but unchanged (status=new) encounters will be updated
#'   if `update_existing=TRUE`, else skipped.
#' * Existing and value-added encounters (status > new) will be skipped.s
#'
#' @param data ODKC data transformed into WAStD format and split into create,
#'   update, skip.
#' @param update_existing Whether to update existing but unchanged records in
#'   WAStD Default: FALSE.
#' @param upload_media Whether to upload media files.
#'   Default: `Sys.getenv("ODKC_IMPORT_UPLOAD_MEDIA", unset=FALSE)`
#' @template param-auth
#' @template param-verbose
#' @return A list of results from `wastdr::wastd_create_update_skip`.
#' @export
upload_odkc_to_wastd <- function(data,
                                 update_existing = FALSE,
                                 up_media = TRUE,
                                 api_url = wastdr::get_wastdr_api_url(),
                                 api_token = wastdr::get_wastdr_api_token(),
                                 verbose = wastdr::get_wastdr_verbose()) {
  res <- list(
    # Tracks ------------------------------------------------------------------#
    tne = wastdr::wastd_create_update_skip(
      data$tne_create,
      data$tne_update,
      data$tne_skip,
      update_existing = update_existing,
      serializer = "turtle-nest-encounters",
      label = "TurtleNestEncounters",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),
    tn_dist = wastdr::wastd_create_update_skip(
      data$tn_dist_create,
      data$tn_dist_update,
      data$tn_dist_skip,
      update_existing = update_existing,
      serializer = "turtle-nest-disturbance-observations",
      label = "TurtleNestDisturbanceObservations",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),
    tn_tags = wastdr::wastd_create_update_skip(
      data$tn_tags_create,
      data$tn_tags_update,
      data$tn_tags_skip,
      update_existing = update_existing,
      serializer = "nest-tag-observations",
      label = "TurtleNestTagObservations",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),
    tn_eggs = wastdr::wastd_create_update_skip(
      data$tn_eggs_create,
      data$tn_eggs_update,
      data$tn_eggs_skip,
      update_existing = update_existing,
      serializer = "turtle-nest-excavations",
      label = "TurtleNestObservations",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),
    th_morph = wastdr::wastd_create_update_skip(
      data$th_morph_create,
      data$th_morph_update,
      data$th_morph_skip,
      update_existing = update_existing,
      serializer = "turtle-hatchling-morphometrics",
      label = "TurtleHatchlingMorphometrics",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),
    th_emerg = wastdr::wastd_create_update_skip(
      data$th_emerg_create,
      data$th_emerg_update,
      data$th_emerg_skip,
      update_existing = update_existing,
      serializer = "turtle-nest-hatchling-emergences",
      label = "TurtleNestHatchlingEmergences",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),
    th_outlier = wastdr::wastd_create_update_skip(
      data$th_outlier_create,
      data$th_outlier_update,
      data$th_outlier_skip,
      update_existing = update_existing,
      serializer = "turtle-nest-hatchling-emergence-outliers",
      label = "TurtleNestHatchlingEmergenceOutliers",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),
    th_light = wastdr::wastd_create_update_skip(
      data$th_light_create,
      data$th_light_update,
      data$th_light_skip,
      update_existing = update_existing,
      serializer = "turtle-nest-hatchling-emergence-light-sources",
      label = "TurtleNestHatchlingEmergenceLightSources",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),

    # tracktally
    tte = wastdr::wastd_create_update_skip(
      data$tte_create,
      data$tte_update,
      data$tte_skip,
      update_existing = update_existing,
      serializer = "line-transect-encounters",
      label = "LineTransectEncounters (Track Tally)",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),
    tto = wastdr::wastd_create_update_skip(
      data$tto_create,
      data$tto_update,
      data$tto_skip,
      update_existing = update_existing,
      serializer = "track-tally",
      label = "LineTransectEncounters (Track Tally) counts",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),
    ttd = wastdr::wastd_create_update_skip(
      data$ttd_create,
      data$ttd_update,
      data$ttd_skip,
      update_existing = update_existing,
      serializer = "turtle-nest-disturbance-tally",
      label = "LineTransectEncounters (Track Tally) dist",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),


    # MWI > AE ----------------------------------------------------------------#
    ae_mwi = wastdr::wastd_create_update_skip(
      data$ae_mwi_create,
      data$ae_mwi_update,
      data$ae_mwi_skip,
      update_existing = update_existing,
      serializer = "animal-encounters",
      label = "AnimalEncounters (MWI)",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),
    obs_turtlemorph = wastdr::wastd_create_update_skip(
      data$obs_turtlemorph_create,
      data$obs_turtlemorph_update,
      data$obs_turtlemorph_skip,
      update_existing = update_existing,
      serializer = "turtle-morphometrics",
      label = "TurtleMorphometrics",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),
    obs_tagobs = wastdr::wastd_create_update_skip(
      data$obs_tagobs_create,
      data$obs_tagobs_update,
      data$obs_tagobs_skip,
      update_existing = update_existing,
      serializer = "tag-observations",
      label = "TagObservations",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),
    obs_turtledmg = wastdr::wastd_create_update_skip(
      data$obs_turtledmg_create,
      data$obs_turtledmg_update,
      data$obs_turtledmg_skip,
      update_existing = update_existing,
      serializer = "turtle-damage-observations",
      label = "TurtleDamageObservations",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),

    # TSI > AE ----------------------------------------------------------------#
    ae_tsi = wastdr::wastd_create_update_skip(
      data$ae_tsi_create,
      data$ae_tsi_update,
      data$ae_tsi_skip,
      update_existing = update_existing,
      serializer = "animal-encounters",
      label = "Animal Encounters (TSI)",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),

    # tracks_log > LO ---------------------------------------------------------#
    lo = wastdr::wastd_create_update_skip(
      data$lo_create,
      data$lo_update,
      data$lo_skip,
      update_existing = update_existing,
      serializer = "logger-observations",
      label = "Logger Observations",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),
    de = wastdr::wastd_create_update_skip(
      data$de_mwi_create,
      data$de_mwi_update,
      data$de_mwi_skip,
      update_existing = update_existing,
      serializer = "encounters",
      label = "Encounters (General Dist)",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    ),
    tnd_obs = wastdr::wastd_create_update_skip(
      data$tnd_obs_create,
      data$tnd_obs_update,
      data$tnd_obs_skip,
      update_existing = update_existing,
      serializer = "turtle-nest-disturbance-observations",
      label = "TurtleNestDisturbanceObservations (General Dist)",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    )
  )
  # Tagging > AE ------------------------------------------------------------#
  if ("tt_create" %in% names(data)) {
    res$tt <- wastdr::wastd_create_update_skip(
      data$tt_create,
      data$tt_update,
      data$tt_skip,
      update_existing = update_existing,
      serializer = "animal-encounters",
      label = "Animal Encounters (TT)",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    )

    res$tt_dmg <- wastdr::wastd_create_update_skip(
      data$tt_dmg_create,
      data$tt_dmg_update,
      data$tt_dmg_skip,
      update_existing = update_existing,
      serializer = "turtle-damage-observations",
      label = "TurtleDamageObservations (TT)",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    )

    res$tt_tsc <- wastdr::wastd_create_update_skip(
      data$tt_tsc_create,
      data$tt_tsc_update,
      data$tt_tsc_skip,
      update_existing = update_existing,
      serializer = "turtle-damage-observations",
      label = "TurtleDamageObservations (TT scars/missed)",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    )

    res$tt_log <- wastdr::wastd_create_update_skip(
      data$tt_log_create,
      data$tt_log_update,
      data$tt_log_skip,
      update_existing = update_existing,
      serializer = "logger-observations",
      label = "Logger Observations (TT)",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    )

    res$tt_mor <- wastdr::wastd_create_update_skip(
      data$tt_mor_create,
      data$tt_mor_update,
      data$tt_mor_skip,
      update_existing = update_existing,
      serializer = "turtle-morphometrics",
      label = "TurtleMorphometrics (TT)",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    )

    res$tt_tag <- wastdr::wastd_create_update_skip(
      data$tt_tag_create,
      data$tt_tag_update,
      data$tt_tag_skip,
      update_existing = update_existing,
      serializer = "tag-observations",
      label = "TagObservations",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    )

    res$tt_nto <- wastdr::wastd_create_update_skip(
      data$tt_nto_create,
      data$tt_nto_update,
      data$tt_nto_skip,
      update_existing = update_existing,
      serializer = "nest-tag-observations",
      label = "TurtleNestTagObservations (TT)",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    )

    res$tt_tno <- wastdr::wastd_create_update_skip(
      data$tt_tno_create,
      data$tt_tno_update,
      data$tt_tno_skip,
      update_existing = update_existing,
      serializer = "turtle-nest-excavations",
      label = "TurtleNestObservations (TT)",
      api_url = api_url,
      api_token = api_token,
      verbose = verbose
    )
  }

  # Surveys come after tagging so they adopt tagging AnimalEncounters in WAStD
  res$svy <- wastdr::wastd_create_update_skip(
    data$svy_create,
    data$svy_update,
    data$svy_skip,
    update_existing = update_existing,
    serializer = "surveys",
    label = "Surveys",
    api_url = api_url,
    api_token = api_token,
    verbose = verbose
  )

  res$survey_media <- upload_survey_media(data$survey_media_create,
    upload = up_media,
    api_url = api_url,
    api_token = api_token,
    verbose = verbose
  )

  res$media <- upload_media(data$media_create,
    upload = up_media,
    api_url = api_url,
    api_token = api_token,
    verbose = verbose
  )

  res
}
