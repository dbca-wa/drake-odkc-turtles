#' Top level helper combining all mapped data ODKC to WAStD
#'
#' @param odkc_data .
#' @param user_mapping .
#' @export
odkc_as_wastd <- function(odkc_data, user_mapping) {
  # TODO: check that each table and each field of odkc_data has been handled
  # TODO: add base_name to encounter/fast/src routers

  list(
    # -------------------------------------------------------------------- #
    # https://wastd.dbca.wa.gov.au/api/1/turtle-nest-encounters/
    # https://github.com/dbca-wa/wastdr/issues/10
    # https://github.com/dbca-wa/wastdr/issues/13
    tne = odkc_tracks_as_wastd_tne(odkc_data$tracks, user_mapping),

    # -------------------------------------------------------------------- #
    # https://wastd.dbca.wa.gov.au/api/1/turtle-nest-disturbance-observations/
    tn_dist = odkc_tracks_dist_as_wastd_tndistobs(odkc_data$tracks_dist),

    # -------------------------------------------------------------------- #
    # https://wastd.dbca.wa.gov.au/api/1/nest-tag-observations/
    tn_tags = odkc_tracks_as_wastd_nesttagobs(odkc_data$tracks),

    # -------------------------------------------------------------------- #
    # https://wastd.dbca.wa.gov.au/api/1/turtle-nest-excavations/
    tn_eggs = odkc_tracks_as_wastd_nestobs(odkc_data$tracks),

    # -------------------------------------------------------------------- #
    # https://wastd.dbca.wa.gov.au/api/1/turtle-hatchling-morphometrics/
    th_morph = odkc_tracks_hatch_as_wastd_thmorph(odkc_data$tracks_hatch),

    # -------------------------------------------------------------------- #
    # https://tsc.dbca.wa.gov.au/api/1/turtle-nest-hatchling-emergences/
    th_emerg = odkc_tracks_as_tnhe(odkc_data$tracks),

    # -------------------------------------------------------------------- #
    # https://wastd.dbca.wa.gov.au/api/1/turtle-nest-hatchling-emergence-outliers/
    th_outlier = odkc_tracks_fan_outlier_as_tnheo(odkc_data$tracks_fan_outlier),

    # -------------------------------------------------------------------- #
    # https://wastd.dbca.wa.gov.au/api/1/turtle-nest-hatchling-emergence-light-sources/
    th_light = odkc_tracks_light_as_wastd_tnhels(odkc_data$tracks_light),

    # -------------------------------------------------------------------- #
    # https://wastd.dbca.wa.gov.au/api/1/logger-encounters/ - now logger obs
    # le = odkc_tracks_log_as_loggerenc(odkc_data$tracks_log, user_mapping),
    # https://wastd.dbca.wa.gov.au/api/1/logger-observations/
    lo = odkc_tracks_log_as_wastd_loggerobs(odkc_data$tracks_log),

    # -------------------------------------------------------------------- #
    # https://wastd.dbca.wa.gov.au/api/1/encounters/
    de = odkc_dist_as_distenc(odkc_data$dist, user_mapping),
    tnd_obs = odkc_dist_as_tndo(odkc_data$dist),

    # -------------------------------------------------------------------- #
    # https://wastd.dbca.wa.gov.au/api/1/animal-encounters/
    # https://github.com/dbca-wa/wastdr/issues/16
    ae_mwi = odkc_mwi_as_wastd_ae(odkc_data$mwi, user_mapping),

    # -------------------------------------------------------------------- #
    # mwi_dmg > damageobs
    # https://github.com/dbca-wa/wastdr/issues/16
    obs_turtledmg = odkc_mwi_dmg_as_wastd_turtledmg(odkc_data$mwi_dmg),

    # -------------------------------------------------------------------- #
    # https://wastd.dbca.wa.gov.au/api/1/tag-observations/
    obs_tagobs = odkc_mwi_tag_as_wastd_tagobs(odkc_data$mwi_tag, user_mapping),

    # -------------------------------------------------------------------- #
    # https://wastd.dbca.wa.gov.au/api/1/turtle-morphometrics/
    # https://github.com/dbca-wa/wastdr/issues/16
    obs_turtlemorph = odkc_mwi_as_wastd_turtlemorph(odkc_data$mwi, user_mapping),

    # -------------------------------------------------------------------- #
    # https://github.com/dbca-wa/wastdr/issues/17
    # https://wastd.dbca.wa.gov.au/api/1/animal-encounters/
    # ae_sightings = odkc_data$tsi
    ae_tsi = odkc_tsi_as_wastd_ae(odkc_data$tsi, user_mapping),

    # -------------------------------------------------------------------- #
    # tracktally > line tx enc, track tally obs, TN dist tally obs
    tte = odkc_tt_as_wastd_lte(odkc_data$track_tally, user_mapping),
    tto = odkc_tt_as_wastd_tto(odkc_data$track_tally),
    ttd = odkc_tt_as_wastd_tndto(odkc_data$track_tally_dist),

    # -------------------------------------------------------------------- #
    # tt turtle tagging
    tt = odkc_tt_as_wastd_ae(odkc_data, user_mapping),
    tt_dmg = odkc_tt_dmg_as_wastd_turtledmg(odkc_data$tt_dmg),
    tt_tsc = odkc_tt_as_wastd_turtledmg(odkc_data$tt),
    tt_log = odkc_tt_log_as_wastd_loggerobs(odkc_data$tt_log),
    tt_mor = odkc_tt_as_wastd_turtlemorph(odkc_data$tt, user_mapping),
    tt_tag = odkc_tt_tag_as_wastd_tagobs(odkc_data, user_mapping),
    tt_nto = odkc_tt_as_wastd_nesttagobs(odkc_data$tt),
    tt_tno = odkc_tt_as_wastd_turtlenestobs(odkc_data$tt),

    # -------------------------------------------------------------------- #
    # https://github.com/dbca-wa/wastdr/issues/15
    # https://wastd.dbca.wa.gov.au/api/1/surveys/
    # make survey end from orphaned sve?
    surveys = odkc_svs_sve_as_wastd_surveys(
      odkc_data$svs, odkc_data$sve, user_mapping),
    survey_media = odkc_as_survey_media(odkc_data),


    # ---------------------------------------------------------------------#
    # https://wastd.dbca.wa.gov.au/api/1/media-attachments/
    media = odkc_as_media(odkc_data)
  )
}
