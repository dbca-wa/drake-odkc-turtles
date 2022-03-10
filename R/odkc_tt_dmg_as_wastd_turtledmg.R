#' Transform odkc_data$tt_dmg into WAStD TurtleDamageObservations.
#'
#' @param data A tibble of turtle damage obs, e.g. \code{odkc_data$tt_dmg}.
#' @return A tibble suitable to
#'   \code{\link{wastd_POST}("turtle-damage-observations")}
#' @export
#' @examples
#' \dontrun{
#' data("odkc_data", package = "wastdr")
#' data("wastd_data", package = "wastdr")
#' au <- Sys.getenv("WASTDR_API_DEV_URL")
#' at <- Sys.getenv("WASTDR_API_DEV_TOKEN")
#' x <- odkc_tt_dmg_as_wastd_turtledmg(odkc_data$tt_dmg)
#' x %>% wastdr::wastd_POST("turtle-damage-observations", api_url = au, api_token = at)
#' }
odkc_tt_dmg_as_wastd_turtledmg <- function(data) {
  data %>%
    # wastdr::sf_as_tbl() %>%
    dplyr::transmute(
      source = 2,
      source_id = id,
      encounter_source = "odk",
      encounter_source_id = submissions_id,
      body_part = body_part,
      damage_type = damage_type,
      damage_age = damage_age,
      description = description
    ) %>%
    dplyr::filter_at(
      dplyr::vars(-source, -source_id, -encounter_source, -encounter_source_id),
      dplyr::any_vars(!is.na(.))
    )
}

# usethis::use_test("odkc_tt_dmg_as_wastd_turtledmg")
