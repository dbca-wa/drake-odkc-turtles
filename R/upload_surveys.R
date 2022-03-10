#' Upload a tibble of Surveys to WAStD
#'
#' @details WAStD's MediaAttachment endpoint uses a plain ModelViewSet and cannot
#' handle multiple uploads. This function therefore uploads records individually.
#' If a file does not exist locally, the record is skipped and a warning is
#' emitted.
#'
#' @param x A tibble of Surveys, e.g. the output of
#'   `odkc_svs_sve_as_wastd_surveys()`.
#'   Note that attachments should be relative or absolute file paths, not
#'   `httr::upload_file()` objects.
#' @template param-auth
#' @template param-verbose
#' @export
upload_surveys <- function(x,
                           api_url = wastdr::get_wastdr_api_url(),
                           api_token = wastdr::get_wastdr_api_token(),
                           verbose = wastdr::get_wastdr_verbose()) {
  if (nrow(x) == 0) {
    wastdr::wastdr_msg_noop(glue::glue("No surveys to upload, skipping."))
    return(x)
  }
  for (i in seq_len(nrow(x))) {
    if (!fs::file_exists(x$start_photo[i])) {
      glue::glue("Missing start photo: {x$start_photo[i]}") %>%
        wastdr::wastdr_msg_info()
      # TODO download start_photo via REST API
    }
    if (!fs::file_exists(x$end_photo[i])) {
      glue::glue("Missing end photo: {x$end_photo[i]}") %>%
        wastdr::wastdr_msg_info()
    }
    list(
      source = x$source[i],
      source_id = x$source_id[i],
      device_id = x$device_id[i],
      start_location = x$start_location[i],
      start_location_accuracy_m = x$start_location_accuracy_m[i],
      start_time = x$start_time[i],
      end_time = x$end_time[i],
      end_location = x$end_location[i],
      end_location_accuracy_m = x$end_location_accuracy_m[i],
      end_comments = x$end_comments[i],
      start_photo = # ifelse(fs::file_exists(x$start_photo[i]),
        httr::upload_file(x$start_photo[i]),
      # NULL),
      end_photo = # ifelse(fs::file_exists(x$end_photo[i]),
        httr::upload_file(x$end_photo[i]),
      # NULL)
    ) %>%
      wastdr::wastd_post_one(
        serializer = "surveys",
        encode = "multipart",
        api_url = api_url,
        api_token = api_token,
        verbose = verbose
      )
  }
}

# dev_url = Sys.getenv("WASTDR_API_DEV_URL")
# dev_tkn = Sys.getenv("WASTDR_API_DEV_TOKEN")
#
