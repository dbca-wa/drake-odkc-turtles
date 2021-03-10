#' ODKC SiteVisitStart/End as WAStD SurveyMediaObservations
#'
#' @param data ODKC Data, e.g. `odkc_data`.
#' @returns A tibble of records which can be uploaded ONE BY ONE to WAStD's
#'   SurveyMediaAttachment API as per function examples.
#'   The field "attachment" has to be turned into an `httr::upload_file` before
#'   upload.
#' @export
#' @examples
#' \dontrun{
#' wastdr::wastdr_setup(api_url = Sys.getenv("WASTDR_API_DEV_URL"),
#'                      api_token = Sys.getenv("WASTDR_API_DEV_TOKEN"))
#' drake::loadd(odkc_ex)
#' x <- odkc_as_survey_media(odkc_ex)
#' upload_survey_media(x[1:10,])
#'
#'
#' # Outside R, using curl (with correct auth token)
#' curl -i -X POST
#'   -H 'Authorization: Token c5575c09f6a0171668f31d5dd5013f02658668bd'
#'   -F 'attachment=@my_photo.jpg'
#'   -F survey_source=odk
#'   -F survey_source_id=5f027f76-7276-11eb-8ce8-e9c53fd9c3f2
#'   -F source=2
#'   -F source_id=5f027f76-7276-11eb-8ce8-e9c53fd9c3f2-photo-start
#'   -F title='Photo site conditions at start of survey'
#'   http://localhost:8220/api/1/survey-media-attachments/
#' }
odkc_as_survey_media <- function(data){
  svs_media <- data$svs %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(site_visit_site_conditions) %>%
    dplyr::filter(site_visit_site_conditions != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-start"),
      survey_source = "odk",
      survey_source_id = id,
      survey_end_source_id = NA,
      media_type = "photograph",
      title = "Photo site conditions at start of survey",
      attachment =  site_visit_site_conditions
    )

  sve_media <- data$sve %>%
    wastdr::sf_as_tbl() %>%
    tidyr::drop_na(site_visit_site_conditions) %>%
    dplyr::filter(site_visit_site_conditions != "NA") %>%
    dplyr::transmute(
      source = 2,
      source_id = glue::glue("{id}-photo-end"),
      survey_source = "odk",
      survey_source_id = NA,
      survey_end_source_id = id,
      media_type = "photograph",
      title = "Photo site conditions at end of survey",
      attachment =  site_visit_site_conditions
    )

  dplyr::bind_rows(svs_media, sve_media)
}
