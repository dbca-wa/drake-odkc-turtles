#' Upload one file or folder to a SharePoint drive
#'
#' Given a local file path, the file is uploaded to
#'
#' @param local_file_path The relative or absolute path to an existing local
#'   file to upload.
#' @param drive_path A SharePoint folder, as returned by `get_item` or
#'   `create_folder` run on a SharePoint Drive.
#' @return NULL
#' @export
upload_item_to_sharepoint <- function(local_file_path,
                                      dst,
                                      local_root_rel="inst/reports"){
  local_root_abs <- here::here(local_root_rel)

  # Catch file does not exist
  if (!fs::file_exists(local_file_path)) {
    "File {} does not exist, skipping" %>%
      glue::glue() %>% wastdr::wastdr_msg_warn()
    return()
  }

  # Destination path shall exclude abs path up to local_root_rel
  dest_pth <- src_fn %>%
    fs::path_dir() %>%
    stringr::str_replace(local_root_abs, "")

  dest_fn <- "{dest_pth}/{fs::path_file(src_fn)}" %>%
    glue::glue() %>%  as.character()

  "Target {dest_fn}" %>%
    glue::glue() %>% wastdr::wastdr_msg_info()

  # Catch file already exists
  if ("ms_drive_item" %in% try(class(dst$get_item(dest_fn)), silent=TRUE)) {
    "Skip existing {dest_fn}" %>%
      glue::glue() %>% wastdr::wastdr_msg_success(msg)
    return()
  }

  if (fs::is_dir(src_fn)) {
    x <- dst$create_folder(dest_fn)
    "Created folder {dest_fn}" %>%
      glue::glue() %>% wastdr::wastdr_msg_success(msg)
  } else {
    x <- dst$upload(src = src_fn, dest = dest_fn)
    "Created file {dest_fn}" %>%
      glue::glue() %>% wastdr::wastdr_msg_success(msg)
  }
}
