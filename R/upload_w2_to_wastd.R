#' Top level helper to upload all Turtle Tagging data to WAStD
#'
#' Encounters and their related observations are uploaded to WAStD:
#'
#' * New encounters will be created
#' * Existing but unchanged (status=new) encounters will be updated
#'   if `update_existing=TRUE`, else skipped.
#' * Existing and value-added encounters (status > new) will be skipped.s
#'
#' @param data W2 data transformed into WAStD format and split into create,
#'   update, skip.
#' @param update_existing Whether to update existing but unchanged records in
#'   WAStD Default: FALSE.
#' @template param-auth
#' @template param-verbose
#' @return A list of results from `wastdr::wastd_create_update_skip`.
#' @export
#' @examples
#' \dontrun{
#' wastdr::wastdr_setup(api_url = Sys.getenv("WASTDR_API_DEV_URL"),
#'                      api_token = Sys.getenv("WASTDR_API_DEV_TOKEN"))
#' wastdr::wastdr_setup(api_url = Sys.getenv("WASTDR_API_TEST_URL"),
#'                      api_token = Sys.getenv("WASTDR_API_TEST_TOKEN"))
#' wastdr::wastdr_setup(api_url = Sys.getenv("WASTDR_API_URL"),
#'                      api_token = Sys.getenv("WASTDR_API_TOKEN"))
#' drake::loadd("w2_up")
#' upload_odkc_to_wastd(w2_up, update_existing=TRUE, verbose=TRUE)
#' }
upload_w2_to_wastd <- function(data,
                                 update_existing = FALSE,
                                 api_url = wastdr::get_wastdr_api_url(),
                                 api_token = wastdr::get_wastdr_api_token(),
                                 verbose = wastdr::get_wastdr_verbose()) {
  res <- list()

  # Tagging > AE ------------------------------------------------------------#
  res$tt = wastdr::wastd_create_update_skip(
    data$tt_create,
    data$tt_update,
    data$tt_skip,
    update_existing = update_existing,
    serializer = "animal-encounters",
    label = "Animal Encounters (W2)",
    api_url = api_url,
    api_token = api_token,
    verbose = verbose
  )

  # Flipper tags
  res$tt_tag = wastdr::wastd_create_update_skip(
    data$tt_tag_create,
    data$tt_tag_update,
    data$tt_tag_skip,
    update_existing = update_existing,
    serializer = "tag-observations",
    label = "TagObservations (flipper tags)",
    api_url = api_url,
    api_token = api_token,
    verbose = verbose
  )

  # PIT tags
  res$tt_pit = wastdr::wastd_create_update_skip(
    data$tt_pit_create,
    data$tt_pit_update,
    data$tt_pit_skip,
    update_existing = update_existing,
    serializer = "tag-observations",
    label = "TagObservations (pit tags)",
    api_url = api_url,
    api_token = api_token,
    verbose = verbose
  )

  # res$tt_dmg = wastdr::wastd_create_update_skip(
  #   data$tt_dmg_create,
  #   data$tt_dmg_update,
  #   data$tt_dmg_skip,
  #   update_existing = update_existing,
  #   serializer = "turtle-damage-observations",
  #   label = "TurtleDamageObservations (TT)",
  #   api_url = api_url,
  #   api_token = api_token,
  #   verbose = verbose
  # )
  #
  # res$tt_tsc = wastdr::wastd_create_update_skip(
  #   data$tt_tsc_create,
  #   data$tt_tsc_update,
  #   data$tt_tsc_skip,
  #   update_existing = update_existing,
  #   serializer = "turtle-damage-observations",
  #   label = "TurtleDamageObservations (TT scars/missed)",
  #   api_url = api_url,
  #   api_token = api_token,
  #   verbose = verbose
  # )

  # res$tt_log = wastdr::wastd_create_update_skip(
  #   data$tt_log_create,
  #   data$tt_log_update,
  #   data$tt_log_skip,
  #   update_existing = update_existing,
  #   serializer = "logger-observations",
  #   label = "Logger Observations (TT)",
  #   api_url = api_url,
  #   api_token = api_token,
  #   verbose = verbose
  # )

  # res$tt_mor = wastdr::wastd_create_update_skip(
  #   data$tt_mor_create,
  #   data$tt_mor_update,
  #   data$tt_mor_skip,
  #   update_existing = update_existing,
  #   serializer = "turtle-morphometrics",
  #   label = "TurtleMorphometrics (TT)",
  #   api_url = api_url,
  #   api_token = api_token,
  #   verbose = verbose
  # )
  #
  # res$tt_nto = wastdr::wastd_create_update_skip(
  #   data$tt_nto_create,
  #   data$tt_nto_update,
  #   data$tt_nto_skip,
  #   update_existing = update_existing,
  #   serializer = "nest-tag-observations",
  #   label = "TurtleNestTagObservations (TT)",
  #   api_url = api_url,
  #   api_token = api_token,
  #   verbose = verbose
  # )
  #
  # res$tt_tno = wastdr::wastd_create_update_skip(
  #   data$tt_tno_create,
  #   data$tt_tno_update,
  #   data$tt_tno_skip,
  #   update_existing = update_existing,
  #   serializer = "turtle-nest-excavations",
  #   label = "TurtleNestObservations (TT)",
  #   api_url = api_url,
  #   api_token = api_token,
  #   verbose = verbose
  # )

  res
}
