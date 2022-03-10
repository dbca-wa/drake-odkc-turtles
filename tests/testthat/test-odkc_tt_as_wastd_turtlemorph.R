test_that("odkc_tt_as_wastd_turtlemorph works", {
  data("odkc_data", package = "wastdr")
  data("wastd_data", package = "wastdr")

  user_mapping <- tibble::tibble(odkc_username = "test", pk = 1)

  # TSC API shows source and source_id under encounter, resolves users
  # curved_carapace_length_min_mm not in example data
  odkc_names <- odkc_data$tt %>%
    odkc_tt_as_wastd_turtlemorph(user_mapping = user_mapping) %>%
    dplyr::select(
      -source, -source_id, -handler_id, -recorder_id,
      -encounter_source_id,
      -curved_carapace_length_min_mm
    ) %>%
    # either exclude handler/recorder_id or rename to _pk
    # dplyr::rename(handler_pk = handler_id, recorder_pk = recorder_id) %>%
    names()

  # ODKC data transformed into TSC shape should contain all fields of the
  # WAStD serializer
  # WAStD accepts handler_id write-only, but returns handler_{pk, username, name}
  # read-only
  for (n in odkc_names) {
    testthat::expect_true(
      n %in% names(wastd_data$turtle_morph),
      label = glue::glue("Column \"{n}\" exists in wastd_data$turtle_morph")
    )
  }
})

# usethis:use_r("odkc_tt_as_wastd_turtlemorph")
