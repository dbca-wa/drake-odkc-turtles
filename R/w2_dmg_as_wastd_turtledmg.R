#' Transform w2_data into WAStD TurtleDamageObservations.
#'
#'
#' @param data Data of class `wamtram_data`.
#' @return A tibble suitable to
#'   \code{\link{wastd_POST}("turtle-damage-observations")}
#' @export
#' @examples
#' \dontrun{
#'
#' }
w2_dmg_as_wastd_turtledmg <- function(data) {

  # data$obs_damages

  tag_sides <- tibble::tribble(
    ~tag_location, ~tag_position,
    "shoulder-left", "LF",
    "shoulder-right", "RF",
    "other", "Other",
    "other", NA
  )

  body_parts <- tibble::tribble(
    ~body_part_code, ~body_part,
    "A", "carapace", #    Carapace - entire
    "B", "flipper-front-left", #   Left front flipper
    "C", "flipper-front-right", #  Right front flipper
    "D", "flipper-rear-left", #    Left rear flipper
    "E", "flipper-rear-right", #   Right rear flipper
    "H", "head", #                 Head
    "I", "carapace", #  Center mid-carapace
    "J", "carapace", # Right front carapace
    "K", "carapace", #  Left front carapace
    "L", "carapace", #   Left rear carapace
    "M", "carapace", #  Right rear carapace
    "N", "carapace", #   Front mid-carapace
    "O", "carapace", #    Rear mid-carapace
    "P", "plastron", #    Plastron - entire
    "T", "tail", #                 Tail
    "W", "whole" #        Whole animal
  )

  # DAMAGE_TYPE_CHOICES = (
  #   # Amputations
  #   ("tip-amputated", "tip amputation"),
  #   ("amputated-from-nail", "amputation from nail"),
  #   ("amputated-half", "half amputation"),
  #   ("amputated-entirely", "entire amputation"),
  #
  #   # Epiphytes and gross things
  #   ("barnacles", "barnacles"),
  #   ("algal-growth", "algal growth"),
  #   ("tumor", "tumor"),
  #
  #   # Tags
  #   ("tag-scar", "tag scar"),
  #   ("tag-seen", "tag seen but not identified"),
  #
  #   # Injuries
  #   ("cuts", "cuts"),
  #   ("boat-strike", "boat or propeller strike"),
  #   ("entanglement", "entanglement"),
  #
  #   # Morphologic aberrations
  #   ("deformity", "deformity"),
  #
  #   # Catch-all
  #   ("other", "other"), )
  #
  damage_type <- tibble::tribble(
    ~damage_code, ~damage_type,
    "0", "other", # None significant
    "1", "tip-amputated", # Tip off - Flipper
    "2", "amputated-from-nail", # Lost from Nail - Flipper
    "3", "amputated-half", # Lost half - Flipper
    "4", "amputated-entirely", # Lost whole - Flipper
    "5", "cuts", # Minor Wounds or cuts
    "6", "cuts", # Major Wounds or cuts
    "7", "deformity", # Deformity
  )

  damage_cause <- tibble::tribble(
    ~damage_cause_code, ~damage_cause,
    "AG", "thick algae",
    "BB", "barnacles",
    "BP", "bite from predator",
    "BT", "bite from turtle",
    "MM", "thick mud",
    "OI", "Other Impact",
    "PS", "parasites (other than barnacles)",
    "SD", "strike damage",
    NA, "not available"
  )

  data %>%
    magrittr::extract2("obs_damages") %>%
    # wastdr::sf_as_tbl() %>%
    dplyr::transmute(
      # https://github.com/dbca-wa/wastd/blob/master/shared/models.py#L259
      source = 20,
      source_id = glue::glue("dmg-{observation_id}-{body_part}-{damage_code}"),
      encounter_source = "wamtram",
      encounter_source_id = as.character(observation_id),
      body_part_code = body_part,
      damage_code = damage_code,
      damage_age = "fresh", # TODO: no damage age in w2 - add NA / indeterminate
      damage_cause_code = damage_cause_code,
      comments = comments
    ) %>%
    dplyr::left_join(body_parts, by = "body_part_code") %>%
    dplyr::left_join(damage_type, by = "damage_code") %>%
    dplyr::left_join(damage_cause, by = "damage_cause_code") %>%
    dplyr::mutate(
      description = glue::glue("{tidyr::replace_na(comments, '')}{tidyr::replace_na(damage_cause, '')}")
    ) %>%
    dplyr::select(
      -body_part_code, -damage_code,
      -damage_cause_code, -damage_cause, -comments
    ) %>%
    dplyr::filter_at(
      dplyr::vars(
        -source, -source_id, -encounter_source, -encounter_source_id,
        -description
      ),
      dplyr::any_vars(!is.na(.))
    )
}


# use_test("w2_dmg_as_wastd_turtledmg")  # nolint
