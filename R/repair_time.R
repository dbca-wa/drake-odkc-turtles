#' Repair a time offset
#'
#' @param dt A datetime to be corrected by a time offset in format readable by
#'   `lubridate::ymd_hms()`, containing the timezone.
#'   E.g. "2010-03-22 20:23:47 +08".
#' @param ref_was A reference datetime for an uncorrected date in a format
#'   readable by `lubridate::ymd_hms()`, containing the timezone.
#'   Default: "2010-03-22 20:08:00 +08".
#' @param ref_should A reference datetime for the corrected `ref_was` in a format
#'   readable by `lubridate::ymd_hms()`, containing the timezone.
#'   Default: "2020-12-28 07:08:00 +08".
#' @param tz The timezone for the corrected datetime,
#'   default: `ruODK::get_default_tz()`.
#' @return The given datetime corrected by the timedelta between `ref_was` and
#'   `ref_should`.
#' @export
#' @examples
#' repair_time("2010-03-03 18:13:01 +08")
repair_time <- function(dt,
                        ref_was = "2010-03-22 20:08:00 +08",
                        ref_should = "2020-12-28 07:08:00 +08",
                        tz = ruODK::get_default_tz()) {
  timediff <- lubridate::ymd_hms(ref_should) - lubridate::ymd_hms(ref_was)
  lubridate::with_tz(lubridate::ymd_hms(dt) + timediff, tz)
}
