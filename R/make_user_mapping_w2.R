#' Generate a WAStD user mapping from a given turtle tagging DB export
#'
#' The matching is done by
#' [`fuzzyjoin::stringdist_left_join`](http://varianceexplained.org/fuzzyjoin/reference/stringdist_join.html)
#' using the Jaro-Winker distance between the ODKC username and the individual
#' WAStD `name`, `username` and `aliases` of current active WAStD Users.
#'
#' The field `aliases` is where the magic happens.
#' `make_user_mapping_w2` matches against each alias after separating the
#' aliases by comma.
#' This way, we can add the exact misspelling of an ODK Collect username as
#' a new alias, and get a 100% match for it.
#'
#'
#' @param wastd_users A tibble of WAStD users.
#' @param w2_data The output of `wastdr::download_w2_data`.
#' @template param-verbose
#' @return A tibble of legacy username and user ID with the respective best
#'   match of a WAStD user.
#' @export
make_user_mapping_w2 <- function(w2_data, wastd_users, verbose = wastdr::get_wastdr_verbose()) {
  glue::glue(
    "Mapping {nrow(w2_data$persons)} WAMTRAM users to ",
    "{nrow(wastd_users)} WAStD user profiles...") %>%
    wastdr::wastdr_msg_info(verbose = verbose)

  unique_legacy_users <-
    w2_data$persons %>%
    tidyr::drop_na(clean_name) %>%
    dplyr::filter(clean_name != "") %>%
    dplyr::mutate(
      clean_name = clean_name %>%
        stringr::str_squish() %>%
        stringr::str_to_lower()
    ) %>%
    dplyr::select(person_id, clean_name) %>%
    unique()

  wastd_users <- wastd_users %>%
    dplyr::filter(is_active = TRUE) %>%
    dplyr::mutate(
      wastd_usernames = paste(username, name, aliases, sep = ",") %>%
        stringr::str_remove_all(",$|,,$") %>%
        stringr::str_to_lower()
    ) %>%
    tidyr::separate_rows(wastd_usernames, sep = ",") %>%
    dplyr::arrange(wastd_usernames) %>%
    dplyr::filter(!duplicated(wastd_usernames)) %>%
    invisible()

  out <- unique_legacy_users %>%
    dplyr::transmute(
      legacy_userid = person_id,
      legacy_username = clean_name
      ) %>%
    fuzzyjoin::stringdist_left_join(
      wastd_users,
      by = c(legacy_username = "wastd_usernames"),
      ignore_case = TRUE,
      method = "jw",
      max_dist = 1000,
      distance_col = "dist"
    ) %>%
    dplyr::group_by(legacy_username) %>%
    dplyr::top_n(1, -dist) %>%
    dplyr::arrange(legacy_username) %>%
    dplyr::ungroup()

  "Done, returning user mapping." %>%
    glue::glue() %>% wastdr::wastdr_msg_success(verbose = verbose)

  out
}
