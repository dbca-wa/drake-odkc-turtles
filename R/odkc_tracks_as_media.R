#' ODKC Tracks as WAStD MediaObservations, WIP.
#' @export
#' @examples
#' \dontrun{
#' wastdr::wastdr_setup(api_url = Sys.getenv("WASTDR_API_DEV_URL"),
#'                      api_token = Sys.getenv("WASTDR_API_DEV_TOKEN"))
#' drake::loadd(odkc_ex)
#' x <- odkc_tracks_as_media(odkc_ex$tracks)
#' # Doesn't work yet:
#' wastdr::wastd_POST(as.list(x[1,]), serializer="media-attachments", encode="multipart")
#' }
odkc_tracks_as_media <- function(data){
  data %>%
    wastdr::sf_as_tbl() %>%
    dplyr::filter(!is.na(track_photos_photo_track_1)) %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-tracks-1"),
      encounter_source="odk",
      encounter_source_id = id,
      media_type = "photograph",
      title = "Photo Track 1",
      attachment = fs::path("media", track_photos_photo_track_1)# %>% make_uploadable
    ) %>%
    dplyr::filter_at(
      dplyr::vars(-source, -source_id, -encounter_source, -encounter_source_id),
      dplyr::any_vars(!is.na(.))
    )
}
