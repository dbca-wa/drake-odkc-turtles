#' Upload a tibble of MediaAttachments to WAStD
#'
#' @details WAStD's MediaAttachment endpoint uses a plain ModelViewSet and cannot
#' handle multiple uploads. This function therefore uploads records individually.
#' If a file does not exist locally, the record is skipped and a warning is
#' emitted.
#'
#' @param x A tibble of MediaAttachments, e.g. the output of `odkc_as_media()`.
#'   Note that media files should be relative or absolute file paths, not
#'   `httr::upload_file()` objects.
#' @template param-auth
#' @template param-verbose
#' @param upload Whether to upload media files.
#'   Default: `Sys.getenv("ODKC_IMPORT_UPLOAD_MEDIA", unset=TRUE)`
#' @export
upload_media <- function(x,
                         api_url = wastdr::get_wastdr_api_url(),
                         api_token = wastdr::get_wastdr_api_token(),
                         verbose = wastdr::get_wastdr_verbose(),
                         upload = Sys.getenv("ODKC_IMPORT_UPLOAD_MEDIA", unset=TRUE)){
  if (upload==FALSE) {
    "Not uploading {nrow(x)} media files." %>%
      glue::glue() %>% wastdr::wastdr_msg_noop()
    return(x)
  }
  if (nrow(x)==0) {
    "No media files to upload, skipping." %>%
      glue::glue() %>% wastdr::wastdr_msg_noop()
    return(x)
  }
  for (i in seq_len(nrow(x))){
    if (fs::file_exists(x$attachment[i])){
      "Uploading photo {x$attachment[i]}" %>%
        glue::glue() %>% wastdr_msg_info()
      list(
        source = x$source[i],
        source_id = x$source_id[i],
        encounter_source = x$encounter_source[i],
        encounter_source_id = x$encounter_source_id[i],
        media_type = x$media_type[i],
        title = x$title[i],
        attachment = httr::upload_file(x$attachment[i])
      ) %>%
        wastdr::wastd_post_one(
          serializer = "media-attachments",
          encode = "multipart",
          api_url = api_url,
          api_token = api_token,
          verbose = verbose
        )
    } else {
      "Skipping missing file {x$attachment[i]}: {x$title[i]}" %>%
        glue::glue() %>% wastdr::wastdr_msg_warn()
    }
  }

  x
}
