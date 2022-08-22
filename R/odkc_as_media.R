#' ODKC Tracks as WAStD MediaObservations
#'
#' @param data ODKC Data, e.g. `odkc_data`.
#' @returns A tibble of records which can be uploaded ONE BY ONE to WAStD's
#'   MediaAttachment API as per function examples. The field "attachment" has to
#'   be turned into an `httr::upload_file` before upload.
#' @export
#' @examples
#' \dontrun{
#' wastdr::wastdr_setup(
#'   api_url = Sys.getenv("WASTDR_API_DEV_URL"),
#'   api_token = Sys.getenv("WASTDR_API_DEV_TOKEN")
#' )
#' drake::loadd(odkc_ex)
#' x <- odkc_as_media(odkc_ex)
#' upload_media(x[1:100, ])
#'
#'
#' # Outside R, using curl (with correct auth token)
#' # curl -i -X POST
#' #   -H 'Authorization: Token xxx'
#' #   -F 'attachment=@my_photo.jpg'
#' #   -F encounter_source=paper
#' #   -F encounter_source_id=2015-01-21-08-00-00-117-152-20-6134-dead-disarticulated-juvenile-na-chelonia-mydas
#' #   -F source=2
#' #   -F source_id=test123
#' #   http://localhost:8220/api/1/media-attachments/
#' }
odkc_as_media <- function(data) {
  tracks <- data$tracks %>%
    wastdr::sf_as_tbl()

  tracks1 <- tracks %>%
    tidyr::drop_na(track_photos_photo_track_1) %>%
    dplyr::filter(track_photos_photo_track_1 != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-tracks-1"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Track 1",
      attachment = track_photos_photo_track_1 # %>% make_uploadable()
    )

  tracks2 <- tracks %>%
    tidyr::drop_na(track_photos_photo_track_2) %>%
    dplyr::filter(track_photos_photo_track_2 != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-tracks-2"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Track 2",
      attachment = track_photos_photo_track_2
    )

  nest1 <- tracks %>%
    tidyr::drop_na(nest_photos_photo_nest_1) %>%
    dplyr::filter(nest_photos_photo_nest_1 != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-nest-1"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Nest 1",
      attachment = nest_photos_photo_nest_1
    )

  nest2 <- tracks %>%
    tidyr::drop_na(nest_photos_photo_nest_2) %>%
    dplyr::filter(nest_photos_photo_nest_2 != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-nest-2"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Nest 2",
      attachment = nest_photos_photo_nest_2
    )

  nest3 <- tracks %>%
    tidyr::drop_na(nest_photos_photo_nest_3) %>%
    dplyr::filter(nest_photos_photo_nest_3 != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-nest-3"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Nest 3",
      attachment = nest_photos_photo_nest_3
    )

  tag <- tracks %>%
    tidyr::drop_na(nest_tag_photo_tag) %>%
    dplyr::filter(nest_tag_photo_tag != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-nest-tag"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Nest Tag",
      attachment = nest_tag_photo_tag
    )

  eggs <- data$tracks_egg %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(photo_eggs) %>%
    dplyr::filter(photo_eggs != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-eggs"),
      encounter_source = "odk",
      encounter_source_id = submissions_id,
      media_type = "photograph",
      title = "Photo Eggs",
      attachment = photo_eggs
    )

  dist <- data$tracks_dist %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(photo_disturbance) %>%
    dplyr::filter(photo_disturbance != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-dist"),
      encounter_source = "odk",
      encounter_source_id = submissions_id,
      media_type = "photograph",
      title = "Photo Disturbance",
      attachment = photo_disturbance
    )

  logg <- data$tracks_log %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(photo_logger) %>%
    dplyr::filter(photo_logger != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-logger"),
      encounter_source = "odk",
      encounter_source_id = submissions_id,
      media_type = "photograph",
      title = "Photo Logger",
      attachment = photo_logger
    )

  tracks_out <- data$tracks_fan_outlier %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(outlier_track_photo) %>%
    dplyr::filter(outlier_track_photo != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-fan-outlier"),
      encounter_source = "odk",
      encounter_source_id = submissions_id,
      media_type = "photograph",
      title = "Photo Hatchling Emergence Track Outlier",
      attachment = outlier_track_photo
    )

  tracks_light <- data$tracks_light %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(light_source_photo) %>%
    dplyr::filter(light_source_photo != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-light-source"),
      encounter_source = "odk",
      encounter_source_id = submissions_id,
      media_type = "photograph",
      title = "Photo Light Source",
      attachment = light_source_photo
    )

  tracks_seawards <- tracks %>%
    tidyr::drop_na(fan_angles_photo_hatchling_tracks_seawards) %>%
    dplyr::filter(fan_angles_photo_hatchling_tracks_seawards != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-hatchling-tracks-seawards"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Hatchling Tracks Seawards",
      attachment = fan_angles_photo_hatchling_tracks_seawards
    )

  tracks_relief <- tracks %>%
    tidyr::drop_na(fan_angles_photo_hatchling_tracks_relief) %>%
    dplyr::filter(fan_angles_photo_hatchling_tracks_relief != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-hatchling-tracks-relief"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Hatchling Tracks Relief",
      attachment = fan_angles_photo_hatchling_tracks_relief
    )

  dist2 <- data$dist %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(disturbanceobservation_photo_disturbance) %>%
    dplyr::filter(disturbanceobservation_photo_disturbance != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-dist"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Disturbance",
      attachment = disturbanceobservation_photo_disturbance
    )

  mwi_ct <- data$mwi %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(photos_turtle_photo_carapace_top) %>%
    dplyr::filter(photos_turtle_photo_carapace_top != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-carapace-top"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Carapace Top",
      attachment = photos_turtle_photo_carapace_top
    )

  mwi_ht <- data$mwi %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(photos_turtle_photo_head_top) %>%
    dplyr::filter(photos_turtle_photo_head_top != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-head-top"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Head Top",
      attachment = photos_turtle_photo_head_top
    )

  mwi_hs <- data$mwi %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(photos_turtle_photo_head_side) %>%
    dplyr::filter(photos_turtle_photo_head_side != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-head-side"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Head Side",
      attachment = photos_turtle_photo_head_side
    )

  mwi_hf <- data$mwi %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(photos_turtle_photo_head_front) %>%
    dplyr::filter(photos_turtle_photo_head_front != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-head-front"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Head Front",
      attachment = photos_turtle_photo_head_front
    )

  mwi_hab1 <- data$mwi %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(incident_photo_habitat) %>%
    dplyr::filter(incident_photo_habitat != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-habitat-1"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Habitat 1",
      attachment = incident_photo_habitat
    )

  mwi_hab2 <- data$mwi %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(habitat_photos_photo_habitat_2) %>%
    dplyr::filter(habitat_photos_photo_habitat_2 != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-habitat-2"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Habitat 2",
      attachment = habitat_photos_photo_habitat_2
    )

  mwi_hab3 <- data$mwi %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(habitat_photos_photo_habitat_3) %>%
    dplyr::filter(habitat_photos_photo_habitat_3 != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-habitat-3"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Habitat 3",
      attachment = habitat_photos_photo_habitat_3
    )

  mwi_hab4 <- data$mwi %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(habitat_photos_photo_habitat_4) %>%
    dplyr::filter(habitat_photos_photo_habitat_4 != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-habitat-4"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Habitat 4",
      attachment = habitat_photos_photo_habitat_4
    )

  # odkc_ex$mwi_tag$photo_tag # no submissions

  # odkc_ex$mwi_dmg$photo_damage
  mwi_dmg <- data$mwi_dmg %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(photo_damage) %>%
    dplyr::filter(photo_damage != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-damage"),
      encounter_source = "odk",
      encounter_source_id = submissions_id,
      media_type = "photograph",
      title = "Photo Damage",
      attachment = photo_damage
    )

  # odkc_ex$tsi$encounter_photo_habitat
  tsi <- data$tsi %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(encounter_photo_habitat) %>%
    dplyr::filter(encounter_photo_habitat != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-habitat"),
      encounter_source = "odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Habitat",
      attachment = encounter_photo_habitat
    )

  if (!is.null(data$tt)) {
    tt_ft1 <- data$tt %>%
      wastdr::sf_as_tbl() %>%
      tidyr::drop_na(ft1_ft1_photo) %>%
      dplyr::filter(ft1_ft1_photo != "NA") %>%
      dplyr::transmute(
        source = 2,
        source_id = glue::glue("{id}-photo-flipper-tag-1"),
        encounter_source = "odk",
        encounter_source_id = id,
        media_type = "photograph",
        title = "Photo Flipper Tag 1",
        attachment = ft1_ft1_photo
      )

    tt_ft2 <- data$tt %>%
      wastdr::sf_as_tbl() %>%
      tidyr::drop_na(ft2_ft2_photo) %>%
      dplyr::filter(ft2_ft2_photo != "NA") %>%
      dplyr::transmute(
        source = 2,
        source_id = glue::glue("{id}-photo-flipper-tag-2"),
        encounter_source = "odk",
        encounter_source_id = id,
        media_type = "photograph",
        title = "Photo Flipper Tag 2",
        attachment = ft2_ft2_photo
      )

    tt_ft3 <- data$tt %>%
      wastdr::sf_as_tbl() %>%
      tidyr::drop_na(ft3_ft3_photo) %>%
      dplyr::filter(ft3_ft3_photo != "NA") %>%
      dplyr::transmute(
        source = 2,
        source_id = glue::glue("{id}-photo-flipper-tag-3"),
        encounter_source = "odk",
        encounter_source_id = id,
        media_type = "photograph",
        title = "Photo Flipper Tag 3",
        attachment = ft3_ft3_photo
      )

    tt_bio <- data$tt %>%
      wastdr::sf_as_tbl() %>%
      tidyr::drop_na(biopsy_biopsy_photo) %>%
      dplyr::filter(biopsy_biopsy_photo != "NA") %>%
      dplyr::transmute(
        source = 2,
        source_id = glue::glue("{id}-photo-biopsy-1"),
        encounter_source = "odk",
        encounter_source_id = id,
        media_type = "photograph",
        title = "Photo Biopsy",
        attachment = biopsy_biopsy_photo
      )

    tt_ds1 <- data$tt %>%
      wastdr::sf_as_tbl() %>%
      tidyr::drop_na(datasheet_photo_datasheet_front) %>%
      dplyr::filter(datasheet_photo_datasheet_front != "NA") %>%
      dplyr::transmute(
        source = 2,
        source_id = glue::glue("{id}-photo-datasheet-1"),
        encounter_source = "odk",
        encounter_source_id = id,
        media_type = "data_sheet",
        title = "Datasheet Front",
        attachment = datasheet_photo_datasheet_front
      )

    tt_ds2 <- data$tt %>%
      wastdr::sf_as_tbl() %>%
      tidyr::drop_na(datasheet_photo_datasheet_rear) %>%
      dplyr::filter(datasheet_photo_datasheet_rear != "NA") %>%
      dplyr::transmute(
        source = 2,
        source_id = glue::glue("{id}-photo-datasheet-2"),
        encounter_source = "odk",
        encounter_source_id = id,
        media_type = "data_sheet",
        title = "Datasheet Rear",
        attachment = datasheet_photo_datasheet_rear
      )

    # odkc_data$tt_tag$tag_photo
    tt_tag <- data$tt_tag %>%
      tidyr::drop_na(tag_photo) %>%
      dplyr::filter(tag_photo != "NA") %>%
      dplyr::transmute(
        source = 2,
        source_id = glue::glue("{id}-photo-tag"),
        encounter_source = "odk",
        encounter_source_id = submissions_id,
        media_type = "photograph",
        title = "Photo Tag",
        attachment = tag_photo
      )
    # odkc_data$tt_dmg$photo_damage
    tt_dmg <- data$tt_dmg %>%
      tidyr::drop_na(photo_damage) %>%
      dplyr::filter(photo_damage != "NA") %>%
      dplyr::transmute(
        source = 2,
        source_id = glue::glue("{id}-photo-damage"),
        encounter_source = "odk",
        encounter_source_id = submissions_id,
        media_type = "photograph",
        title = "Photo Tag",
        attachment = photo_damage
      )
    # odkc_data$tt_log%logger_photo
    tt_log <- data$tt_log %>%
      tidyr::drop_na(logger_photo) %>%
      dplyr::filter(logger_photo != "NA") %>%
      dplyr::transmute(
        source = 2,
        source_id = glue::glue("{id}-photo-logger"),
        encounter_source = "odk",
        encounter_source_id = submissions_id,
        media_type = "photograph",
        title = "Photo Logger",
        attachment = logger_photo
      )

    tt_media <- dplyr::bind_rows(
      tt_ft1,
      tt_ft2,
      tt_ft3,
      tt_bio,
      tt_ds1,
      tt_ds2,
      tt_tag,
      tt_dmg,
      tt_log
    )
  }

  res <- dplyr::bind_rows(
    tracks1,
    tracks2,
    nest1,
    nest2,
    nest3,
    tag,
    eggs,
    dist,
    logg,
    tracks_out,
    tracks_light,
    tracks_seawards,
    tracks_relief,
    dist2,
    tsi,
    mwi_dmg,
    mwi_hab1,
    mwi_hab2,
    mwi_hab3,
    mwi_hab4,
    mwi_ct,
    mwi_ht,
    mwi_hs,
    mwi_hf
  )

  if (!is.null(data$tt)) {
    dplyr::bind_rows(res, tt_media)
  } else {
    res
  }
}
