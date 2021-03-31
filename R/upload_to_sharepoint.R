#' Upload all outputs to various SharePoint sites
#'
#' @export
upload_to_sharepoint <- function(){
  # https://github.com/Azure/AzureR
  # https://github.com/Azure/Microsoft365R
  # devtools::install_github("Azure/Microsoft365R")
  # devtools::install_github("Azure/AzureAuth")
  # library(AzureAuth)
  library(Microsoft365R)

  # Trigger authentication
  teams <- list_teams()

  # Upload all files to internal group TurtleData
  dst <- get_todays_folder_sharepoint("TurtleData")
  source_files <- fs::dir_ls(here::here("inst/reports"), recurse = TRUE)
  for (src_fn in source_files) {upload_item_to_sharepoint(src_fn, dst)}
  notify_teams_data("TurtleData")

  # Upload DEL / WPTP to Rio
  dst_rio <- get_todays_folder_sharepoint("Turtles Rio Tinto")
  source_files_del <- fs::dir_ls(here::here("inst/reports"), recurse = TRUE, regex="delambre")
  source_files_wptp <- fs::dir_ls(here::here("inst/reports"), recurse = TRUE, regex="west-pilbara")
  source_files_qa <- fs::dir_ls(here::here("inst/reports"), regex="qa_")
  for (src_fn in source_files_del) {upload_item_to_sharepoint(src_fn, dst_rio)}
  for (src_fn in source_files_wptp) {upload_item_to_sharepoint(src_fn, dst_rio)}
  for (src_fn in source_files_qa) {upload_item_to_sharepoint(src_fn, dst_rio)}
  notify_teams_data("Turtles Rio Tinto")

  # Upload PtH to C4H
  # shpt <- Microsoft365R::get_sharepoint_site("Turtles C4H")
  dst_cfh <- get_todays_folder_sharepoint("Turtles C4H")
  source_files_pth <- fs::dir_ls(here::here("inst/reports"), recurse = TRUE, regex="hedland")
  source_files_qa <- fs::dir_ls(here::here("inst/reports"), regex="qa_")
  for (src_fn in source_files_pth) {upload_item_to_sharepoint(src_fn, dst_cfh)}
  for (src_fn in source_files_qa) {upload_item_to_sharepoint(src_fn, dst_cfh)}
  notify_teams_data("Turtles C4H")

  # Upload what to Pendoley?
  # dst_pen <- get_todays_folder_sharepoint("Turtles Pendoley")
}
