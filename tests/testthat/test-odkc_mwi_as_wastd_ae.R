test_that("odkc_mwi_as_wastd_ae works", {
  data("odkc_data", package = "wastdr")
  # data("wastd_data", package = "wastdr") # dumb luck: no comments in first 1k records
  data("wastd_ae", package = "wastdr")

  user_mapping <- tibble::tibble(odkc_username = "test", pk = 1)

  # TSC API shows source and source_id under encounter, resolves users
  odkc_names <- odkc_data$mwi %>%
    odkc_mwi_as_wastd_ae(user_mapping = user_mapping) %>%
    dplyr::select(-source, -source_id, -where, -reporter_id, -observer_id, -when) %>%
    names()

  # ODKC data transformed into TSC shape should contain all fields of the
  # WAStD serializer
  for (n in odkc_names) {
    testthat::expect_true(
      n %in% names(wastd_ae),
      label = glue::glue("Column \"{n}\" exists in wastd_ae")
    )
  }
})

# usethis::use_r("odkc_mwi_as_wastd_ae")
