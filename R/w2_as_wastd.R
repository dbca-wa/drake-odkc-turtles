#' Transform W2 data into WAStD data
#'
#' This function calls one function to produce the data for each API endpoint.
#'
#' @param data Data of class `wamtram_data`.
#' @param user_mapping The output of `make_user_mapping_w2()`.
#' @return A tibble suitable for `split_create_update_skip()`.
#' @family wamtram
#' @export
w2_as_wastd <- function(data, user_mapping){
  list(
    tt = w2_as_wastd_ae(data, user_mapping),
    tt_tag = w2_tag_as_wastd_tagobs(data, user_mapping),
    tt_pit = w2_pit_as_wastd_tagobs(data)
    # w2data$obs_flippertags > tagobs (utils.py:1842)
    # tt_dmg = w2_dmg_as_wastd_turtledmg(odkc_data$tt_dmg),
    # tt_tsc = w2_as_wastd_turtledmg(odkc_data$tt),
    # tt_log = w2_log_as_wastd_loggerobs(odkc_data$tt_log),
    # tt_mor = w2_as_wastd_turtlemorph(odkc_data$tt, user_mapping),
    #
    # tt_nto = w2_as_wastd_nesttagobs(odkc_data$tt),
    # tt_tno = w2_as_wastd_turtlenestobs(odkc_data$tt)
  )
}
