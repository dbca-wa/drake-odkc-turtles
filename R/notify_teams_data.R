#' Notify a Team's channel about refreshed data.
#'
#' @param team_name An existing Team name, e.g. "TurtleData", "TurtlesRioTinto",
#'   "TurtlesC4H", "TurtlesPendoley".
#' @param channel_name An existing Teams channel name, default: "Data".
#' @return NULL
#' @export
notify_teams_data <- function(team_name, channel_name="Data"){
  msg <- glue::glue("Data exported from WAStD on {Sys.time()} to {pth}")
  Microsoft365R::get_team(team_name)$get_channel(channel_name)$send_message(msg)
}
