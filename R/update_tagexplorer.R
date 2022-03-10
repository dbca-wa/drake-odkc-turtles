#' Update the Google Sheet "Turtle Tag Explorer"
#'
#' This function first authenticates (out of band) against a Google account
#' given through the email `Sys.getenv("GOOGLE_EMAIL")`.
#' Next, selected columns of `wastd_data$turtle_tags` are written over an
#' existing sheet "Tags" in the Google Sheet with ID
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
#' @return A list with keys:
#'
#' * `tags` The selected columns and (all) rows of `wastd_data$turtle_tags`.
#' * `tag_sheet` The Google sheet ID for the sheet containing `tags`.
#' * `meta_sheet` The Google sheet ID for the sheet containing the metadata.
#' @export
update_tagexplorer <- function(wastd_data,
                               doc_id = Sys.getenv("TURTLE_SHEET")) {
  #
  # googledrive::drive_auth(path = service_account_token)
  #
  # googlesheets4::gs4_auth_configure(api_key = Sys.getenv("GOOGLE_MAPS_APIKEY"))


  tags <- wastd_data$turtle_tags %>%
    dplyr::select(
      encounter_when,
      encounter_site_name,
      name,
      status,
      tag_location,
      encounter_name,
      comments,
      encounter_absolute_admin_url
    ) %>%
    dplyr::mutate(
      url = glue::glue(
        "https://wastd.dbca.wa.gov.au{encounter_absolute_admin_url}"
      )
    ) %>%
    dplyr::select(-encounter_absolute_admin_url)

  cell_count <- nrow(tags) * ncol(tags)
  if (cell_count > 5000000) {
    wastdr::wastdr_msg_abort(glue::glue(
      "Exceeding Google Sheets limit of 5M cells ",
      "with {nrow(tags)} rows and {ncol(tags)} cols."
    ))
  }

  wastdr::wastdr_msg_info(
    glue::glue(
      "Updating Google Sheet 'Turtle Tag Explorer': ",
      "{nrow(tags)} Tags, {cell_count} cells"
    )
  )
  tag_sheet <- tags %>% googlesheets4::sheet_write(doc_id, sheet = "Tags")
  wastdr::wastdr_msg_success("Done.")

  wastdr::wastdr_msg_info("Updating Google Sheets 'Turtle Tag Explorer': Meta")
  meta <- tibble::tibble(
    data_retrieved_utc = wastd_data$downloaded_on,
    sheet_updated_utc = Sys.time(),
    number_of_records = nrow(wastd_data$turtle_tags)
  ) %>%
    googlesheets4::sheet_write(Sys.getenv("TURTLE_SHEET"), sheet = "Metadata")
  wastdr::wastdr_msg_success("Done.")

  list(tags = tags, tag_sheet = tag_sheet, meta_sheet = meta)
}
