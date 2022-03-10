#' Transform odkc_data$tt into WAStD TurtleDamageObservations (scars, missed
#' tags)
#'
#' @param data A tibble of turtle tagging data, e.g. \code{odkc_data$tt}.
#' @return A tibble suitable to
#'   \code{\link{wastd_POST}("turtle-damage-observations")}
#' @export
#' @examples
#' \dontrun{
#' data("odkc_data", package = "wastdr")
#' au <- Sys.getenv("WASTDR_API_DEV_URL")
#' at <- Sys.getenv("WASTDR_API_DEV_TOKEN")
#' x <- odkc_tt_as_wastd_turtledmg(odkc_data$tt)
#' x %>% wastdr::wastd_POST("turtle-damage-observations",
#'   api_url = au, api_token = at
#' )
#' }
odkc_tt_as_wastd_turtledmg <- function(data) {
  scars <- data %>%
    wastdr::sf_as_tbl() %>%
    dplyr::transmute(
      source = 2,
      source_id = id,
      encounter_source = "odk",
      encounter_source_id = id,
      body_part = ft1_tag_scar_locations,
      damage_type = "tag-scar",
      damage_age = "healed-entirely"
    ) %>%
    dplyr::filter(!is.na(body_part)) %>%
    dplyr::filter(body_part != "none") %>%
    tidyr::separate_rows(body_part, sep = " ")

  missed <- data %>%
    wastdr::sf_as_tbl() %>%
    dplyr::transmute(
      source = 2,
      source_id = id,
      encounter_source = "odk",
      encounter_source_id = id,
      body_part = ft1_tag_sighted_but_unread,
      damage_type = "tag-seen",
      damage_age = "healed-entirely"
    ) %>%
    dplyr::filter(!is.na(body_part)) %>%
    dplyr::filter(body_part != "none") %>%
    tidyr::separate_rows(body_part, sep = " ")

  # The same source_id can have multiple scars/missed tags,
  # which need unique IDs
  dplyr::bind_rows(scars, missed) %>%
    dplyr::mutate(
      source_id = glue::glue("{source_id}-{damage_type}-{body_part}")
    )
}

# usethis::use_test("odkc_tt_as_wastd_turtledmg")
