#' Update the Google Sheet "Turtle Tag Explorer"
#'
#' This function first authenticates (out of band) against a Google account
#' given through the email `Sys.getenv("GOOGLE_MAPS_APIKEY")`.
#' Next, selected columns of tagged `wastd_data$animals` are written over an
#' existing sheet "Encounters" in the Google Sheet with ID
#' `Sys.getenv("TURTLE_SHEET")`.
#' Lastly, metadata (number of records, data accessed on, data uploaded on) are
#' written to a sheet "Metadata".
#' Messages choose verbosity from `wastdr::get_wastdr_verbose()`.
#'
#' Should the total number of cells exceed the Google Sheet limit of 5M cells,
#' this function aborts with an informative error message.
#'
#' @param wastd_data The output of `wastdr::download_wastd_turtledata()`..
#' @param doc_id The Google Sheet ID, default: `Sys.getenv("TURTLE_SHEET")`.
#' @param api_key A Google API key, default: `Sys.getenv("GOOGLE_MAPS_APIKEY")`.
#' @return A list with keys:
#'
#' * `enc` The selected columns and (all) rows of tagged `wastd_data$animals`.
#' * `enc_sheet` The Google sheet ID for the sheet containing `encounters`.
#' * `meta_sheet` The Google sheet ID for the sheet containing the metadata.
#' @export
update_tagexplorer <- function(wastd_data,
                               doc_id = Sys.getenv("TURTLE_SHEET"),
                               api_key = Sys.getenv("GOOGLE_MAPS_APIKEY")) {
  #
  # googledrive::drive_auth(path = service_account_token)
  #
  googlesheets4::gs4_auth_configure(api_key = api_key)

  enc <- wastd_data$animals %>%
    dplyr::filter(!is.na(name)) %>%
    dplyr::select(
      id,
      datetime,
      site_name,
      identifiers,
      sighting_status,
      sighting_status_reason,
      site_of_last_sighting_name,
      datetime_of_last_sighting
    ) %>%
    dplyr::mutate(
      url = glue::glue(
        "https://wastd.dbca.wa.gov.au/observations/animal-encounters/{id}"
      )
    ) %>%
    dplyr::select(-id)

  cell_count <- nrow(enc) * ncol(enc)
  if (cell_count > 5000000) {
    wastdr::wastdr_msg_abort(glue::glue(
      "Exceeding Google Sheets limit of 5M cells ",
      "with {nrow(tags)} rows and {ncol(tags)} cols."
    ))
  }

  wastdr::wastdr_msg_info(
    glue::glue(
      "Updating Google Spreadsheet 'Turtle Tag Explorer': ",
      "Sheet 'Encounters' {nrow(enc)} rows, {cell_count} total cells."
    )
  )
  enc_sheet <- enc %>% googlesheets4::sheet_write(doc_id, sheet = "Encounters")
  wastdr::wastdr_msg_success("Done.")

  wastdr::wastdr_msg_info("Updating Google Sheets 'Turtle Tag Explorer': Meta")
  meta <- tibble::tibble(
    data_retrieved_utc = wastd_data$downloaded_on,
    sheet_updated_utc = Sys.time(),
    number_of_records = nrow(wastd_data$animals)
  ) %>%
    googlesheets4::sheet_write(Sys.getenv("TURTLE_SHEET"), sheet = "Metadata")
  wastdr::wastdr_msg_success("Done.")

  list(enc = enc, enc_sheet = enc_sheet, meta_sheet = meta)
}
