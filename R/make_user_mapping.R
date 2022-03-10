#' Generate a WAStD user mapping from a given list of ODKC data.
#'
#' The matching is done by
#' [`fuzzyjoin::stringdist_left_join`](http://varianceexplained.org/fuzzyjoin/reference/stringdist_join.html)
#' using the Jaro-Winker distance between the ODKC username and the individual
#' WAStD `name`, `username` and `aliases` of current active WAStD Users.
#'
#' The field `aliases` is where the magic happens. `make_user_mapping` matches
#' against each alias after separating the aliases by comma.
#' This way, we can add the exact misspelling of an ODK Collect username as
#' a new alias, and get a 100% match for it.
#'
#' Extract all unique reporter names from odkc data.
#' Extract relevant user names from WAStD users.
#' Map most likely match and export to CSV.
#' External QA: review mapping, update WAStD user aliases to improve the
#' user matching process. Re-run until optimized, edit CSV to improve match.
#' Return a named list containing the mapping of odkc_reporter and wastd_user_id.
#'
#' @param odkc_data The output of `wastdr::download_all_odkc_turtledata_2019`.
#' @param wastd_users A tibble of WAStD users
#' @template param-verbose
#' @export
make_user_mapping <- function(odkc_data, wastd_users,
                              verbose = wastdr::get_wastdr_verbose()) {
  if (!is.null(odkc_data$tt)) {
    tagging_names <- unique(
      c(
        odkc_data$tt$encounter_handler,
        odkc_data$tt$ft1_ft1_handled_by,
        odkc_data$tt$ft2_ft2_handled_by,
        odkc_data$tt$ft3_ft3_handled_by,
        odkc_data$tt$morphometrics_morphometrics_handled_by,
        odkc_data$tt_tag$tag_handled_by
      )
    )
  } else {
    tagging_names <- c()
  }

  odkc_reporters <-
    c(
      tagging_names,
      odkc_data$tracks$reporter,
      odkc_data$track_tally$reporter,
      odkc_data$dist$reporter,
      odkc_data$mwi$reporter,
      odkc_data$svs$reporter,
      odkc_data$sve$reporter,
      odkc_data$tsi$reporter
    ) %>%
    tidyr::replace_na("Turtles") %>%
    stringr::str_squish() %>%
    stringr::str_to_lower() %>%
    unique()


  glue::glue(
    "Mapping {nrow(odkc_reporters)} ODKC usernames to ",
    "{nrow(wastd_users)} WAStD user profiles..."
  ) %>%
    wastdr::wastdr_msg_info(verbose = verbose)

  w_users <- wastd_users %>%
    dplyr::filter(is_active == TRUE) %>%
    dplyr::mutate(
      wastd_usernames = paste(username, name, aliases, sep = ",") %>%
        stringr::str_remove_all(",$|,,$") %>%
        stringr::str_to_lower()
    ) %>%
    tidyr::separate_rows(wastd_usernames, sep = ",") %>%
    dplyr::mutate(
      wastd_usernames = wastd_usernames %>% stringr::str_squish()
    ) %>%
    dplyr::arrange(wastd_usernames) %>%
    dplyr::filter(!duplicated(wastd_usernames)) %>%
    invisible()

  out <- tibble::tibble(
    odkc_username = odkc_reporters
  ) %>%
    fuzzyjoin::stringdist_left_join(
      w_users,
      by = c("odkc_username" = "wastd_usernames"),
      ignore_case = TRUE,
      method = "jw",
      max_dist = 1000,
      distance_col = "dist"
    ) %>%
    dplyr::group_by(odkc_username) %>%
    dplyr::top_n(1, -dist) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(odkc_username)
  # %>% dplyr::select(-odkc_un_trim)

  "Done, returning user mapping." %>%
    glue::glue() %>%
    wastdr::wastdr_msg_success(verbose = verbose)

  out
}
