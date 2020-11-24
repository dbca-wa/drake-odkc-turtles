#' Generate a map of odkc_ex$tracks for a given username
#'
#' @export
#' @examples
#' \dontrun{
#' drake::loadd("odkc_ex")
#' map_unknown_user(odkc_ex, "Janani Nakulan")
#' }
map_unknown_user <- function(odkc_data, odkc_username) {
  odkc_data$tracks %>%
    dplyr::filter(reporter == odkc_username) %>%
    map_tracks_odkc(sites = odkc_data$sites)
}

map_unknown_users <- function(odkc_data, user_mapping) {
  user_mapping_report <- user_mapping %>%
    annotate_user_mapping() %>%
    pointblank::create_agent() %>%
    pointblank::col_vals_lt("dist", 0.01) %>%
    interrogate() %>%
    pointblank::get_data_extracts() %>%
    magrittr::extract2(1)

  usernames <- user_mapping_report$odkc_username %>% unique()
  for (un in usernames) {
    map_unknown_user(odkc_data, un)
  }
}


#' Return a comma-separated list of area_names for a given username from odkc_data
#'
#' @export
#' @examples
#' \dontrun{
#' drake::loadd("odkc_ex")
#' get_user_area(odkc_ex, "Janani Nakulan")
#' get_user_area(odkc_ex, "Kloe Ams")
#' get_user_area(odkc_ex, "jessica mcglashan, ashley bachert")
#' get_user_area(odkc_ex, "Melanie Lambert, Elena Miller")
#' }
get_user_area <- function(odkc_data, username){
  tracks <- odkc_data$tracks %>%
    dplyr::filter(reporter == username) %>%
    wastdr::sf_as_tbl() %>%
    dplyr::select(area_name) %>%
    unique()

  mwi <- odkc_data$mwi %>%
    dplyr::filter(reporter == username) %>%
    wastdr::sf_as_tbl() %>%
    dplyr::select(area_name) %>%
    unique()

  svs <- odkc_data$svs %>%
    dplyr::filter(reporter == username) %>%
    wastdr::sf_as_tbl() %>%
    dplyr::select(area_name) %>%
    unique()

  c(tracks$area_name, mwi$area_name, svs$area_name) %>%
    unique() %>%
    paste(sep = ", ", collapse = ",")
}
