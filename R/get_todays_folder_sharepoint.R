#' Get a folder with the current date from a SharePoint site's "General" drive
#'
#' @param team_name An existing Team name, e.g. "TurtleData", "TurtlesRioTinto",
#'   "TurtlesC4H", "TurtlesPendoley".
#' @return The Microsoft365R R6 object for a shared folder named
#'   `General/YYYY-MM-DD` with today's date.
#' @export
get_todays_folder_sharepoint <- function(team_name) {
  team <- Microsoft365R::get_team(team_name)
  team_shp <- team$get_sharepoint_site()
  team_docs <- team_shp$get_drive()

  today_date <- as.character(Sys.Date())
  pth <- as.character(glue::glue("General/{today_date}"))
  if (today_date %in% team_docs$list_items(path = "/General")$name) {
    dst <- team_docs$get_item(pth)
  } else {
    dst <- team_docs$create_folder(pth)
  }
  dst
}
