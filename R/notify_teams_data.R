#' Notify a Team's channel about refreshed data.
#'
#' @param team_name An existing Team name, e.g. "TurtleData", "TurtlesRioTinto",
#'   "TurtlesC4H", "TurtlesPendoley".
#' @param drive_item The MS SharePoint Drive item (a folder)
#' @param channel_name An existing Teams channel name, default: "Data".
#' @return NULL
#' @export
notify_teams_data <- function(team_name, drive_item, channel_name="Data"){
  msg <- glue::glue("Data exported from WAStD on {Sys.time()} ",
                    "to the linked SharePoint's drive ",
                    "General/{as.character(Sys.Date())}.\n",
                    "Sharing link: {dst$create_share_link(type=\"view\")}")
  Microsoft365R::get_team(team_name)$get_channel(channel_name)$send_message(msg)
}
