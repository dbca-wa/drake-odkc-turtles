#' Upload all outputs to various SharePoint sites
#'
#' Refresh tokens:
#'
#' See https://github.com/Azure/Microsoft365R/blob/master/vignettes/auth.Rmd
#' If token expires, run the next two lines by hand:
#'
#' options(microsoft365r_use_cli_app_id=TRUE)
#' teams <- list_teams()
#'
#' Reset tokens:
#'
#' AzureAuth::clean_token_directory()
#' AzureGraph::delete_graph_login(tenant="dbca")
#'
#' @param wastd_reports The result from `generate_wastd_reports()`
#'   is used here to declare a dependency of this step to the reports being
#'   generated.
#' @export
upload_to_sharepoint <- function(wastd_reports = NULL){
  # https://github.com/Azure/AzureR
  # https://github.com/Azure/Microsoft365R
  # devtools::install_github("Azure/Microsoft365R")
  # devtools::install_github("Azure/AzureAuth")
  # library(AzureAuth)
  library(Microsoft365R)

  # Trigger authentication
  # See https://github.com/Azure/Microsoft365R/blob/master/vignettes/auth.Rmd
  # If token expires, run the next two lines by hand:
  # options(microsoft365r_use_cli_app_id=TRUE)
  teams <- list_teams()
  # If tokens are stale:
  # AzureAuth::clean_token_directory()
  # AzureGraph::delete_graph_login(tenant="dbca")

  # Upload all files to internal group TurtleData
  dst <- get_todays_folder_sharepoint("TurtleData")
  source_files <- fs::dir_ls(here::here("inst/reports"), recurse = TRUE)
  for (src_fn in source_files) {upload_item_to_sharepoint(src_fn, dst)}
  notify_teams_data("TurtleData", dst)

  # Upload DEL / WPTP to Rio
  dst_rio <- get_todays_folder_sharepoint("Turtles Rio Tinto")
  source_files_del <- fs::dir_ls(here::here("inst/reports"), recurse = TRUE, regex="delambre")
  source_files_wptp <- fs::dir_ls(here::here("inst/reports"), recurse = TRUE, regex="cape-lambert|caravan-park")
  # add del_rio when approved
  # source_files_rio <- fs::dir_ls(here::here("inst/reports"), recurse = TRUE, regex="rio")
  source_files_qa <- fs::dir_ls(here::here("inst/reports"), regex="qa_")
  for (src_fn in source_files_del) {upload_item_to_sharepoint(src_fn, dst_rio)}
  for (src_fn in source_files_wptp) {upload_item_to_sharepoint(src_fn, dst_rio)}
  # add del_rio when approved
  # for (src_fn in source_files_rio) {upload_item_to_sharepoint(src_fn, dst_rio)}
  for (src_fn in source_files_qa) {upload_item_to_sharepoint(src_fn, dst_rio)}
  notify_teams_data("Turtles Rio Tinto", dst_rio)

  # Upload PtH to C4H
  # shpt <- Microsoft365R::get_sharepoint_site("Turtles C4H")
  dst_cfh <- get_todays_folder_sharepoint("Turtles C4H")
  source_files_pth <- fs::dir_ls(here::here("inst/reports"), recurse = TRUE, regex="hedland")
  source_files_qa <- fs::dir_ls(here::here("inst/reports"), regex="qa_")
  for (src_fn in source_files_pth) {upload_item_to_sharepoint(src_fn, dst_cfh)}
  for (src_fn in source_files_qa) {upload_item_to_sharepoint(src_fn, dst_cfh)}
  notify_teams_data("Turtles C4H", dst_cfh)

  # Upload what to Pendoley?
  # dst_pen <- get_todays_folder_sharepoint("Turtles Pendoley")
}
