#' Transform w2_data into WAStD TurtleDamageObservations for tag scars.
#'
#'
#' w2_data$obs_flipper_tags of tag_status M and M1 become
#' WAStD TurtleDamageObservations of damage_type tag-scar.
#'
#' @param data Data of class `wamtram_data`.
#' @return A tibble suitable to
#'   \code{\link{wastd_POST}("turtle-damage-observations")}
#' @export
#' @examples
#' \dontrun{
#'
#' }
w2_tag_as_wastd_turtledmg <- function(data) {
  body_parts <- tibble::tribble(
    ~body_part, ~attached_on_side, ~tag_position,
    "flipper-front-left-1", "L", 1,
    "flipper-front-left-2", "L", 2,
    "flipper-front-left-3", "L", 3,
    "flipper-front-left", "L", NA,
    "flipper-front-right-1", "R", 1,
    "flipper-front-right-2", "R", 2,
    "flipper-front-right-3", "R", 3,
    "flipper-front-right", "R", NA
  )

  data %>%
    magrittr::extract2("obs_flipper_tags") %>%
    dplyr::filter(tag_state %in% c("M", "M1")) %>%
    # wastdr::sf_as_tbl() %>%
    dplyr::transmute(
      # https://github.com/dbca-wa/wastd/blob/master/shared/models.py#L259
      source = 20,
      source_id = glue::glue("dmg-{observation_id}-tag-scar"),
      source_id = as.character(recorded_tag_id),
      encounter_source = "wamtram",
      encounter_source_id = as.character(observation_id),
      damage_age = "healed-entirely", # TODO: no damage age in w2 - add NA / indeterminate
      damage_type = "tag-scar",
      attached_on_side = attached_on_side,
      tag_position = tag_position,
      comments = comments,
      turtle_id = turtle_id
    ) %>%
    dplyr::left_join(body_parts, by = c("attached_on_side", "tag_position")) %>%
    dplyr::mutate(
      description = "W2 turtle ID {turtle_id} {tidyr::replace_na(comments, '')}" %>%
        glue::glue() %>% stringr::str_trim()
    ) %>%
    dplyr::select(-attached_on_side, -tag_position, -comments, -turtle_id) %>%
    dplyr::filter_at(
      dplyr::vars(
        -source, -source_id, -encounter_source, -encounter_source_id,
        -description
      ),
      dplyr::any_vars(!is.na(.))
    )
}


# use_test("w2_tag_as_wastd_turtledmg")  # nolint
