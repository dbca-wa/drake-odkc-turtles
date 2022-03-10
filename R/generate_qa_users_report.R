#' Generate QA report for user mapping
#'
#' @export
#' @examples
#' \dontrun{
#' generate_qa_users_report(odkc_ex, user_mapping, wastd_data_yr)
#' }
generate_qa_users_report <- function(odkc_ex, user_mapping, year, skip=FALSE) {
  if (skip==TRUE) {
    wastdr::wastdr_msg_info(glue::glue("Skipping QA for user mapping"))
    return(NULL)
  }

  wastdr::wastdr_msg_info(glue::glue("Rendering QA for users in {year}..."))
  fn_out <-
    here::here("vignettes", glue::glue("qa_users{year}.html"))

  # TODO in the Docker image this resolves to /root/vignettes/qa_users.Rmd
  fn_in <- here::here("vignettes", "qa_users.Rmd")

  if (!fs::file_exists(fn_in)) {
    fn_in <- "/app/vignettes/qa_users.Rmd"
  }
  if (!fs::file_exists(fn_out)) {
    fn_out <- glue::glue("/app/vignettes/qa_users{year}.Rmd")
  }

  user_qa_report <- rmarkdown::render(
    fn_in,
    output_file = fn_out,
    quiet = FALSE
  )
  wastdr::wastdr_msg_success(glue::glue("Report {fn_out} copied to inst/reports."))
  fs::file_copy(fn_out, here::here("inst/reports/"), overwrite = TRUE)
}

#' Generate QA report for W2 user mapping
#'
#' @export
#' @examples
#' \dontrun{
#' generate_qa_users_report(odkc_ex, user_mapping, wastd_data_yr)
#' }
generate_qa_users_report_w2 <- function(user_mapping,
                                        w2_yr,
                                        w2_data,
                                        verbose = wastdr::get_wastdr_verbose()) {
  fn_in <- here::here("vignettes/qa_users_w2.Rmd")
  fn_out <- here::here("inst/reports/qa_users_w2.html")
  "Rendering QA for WAMTRAM users to {fn_out}..." %>%
    glue::glue() %>%
    wastdr::wastdr_msg_info(verbose = verbose)
  user_qa_report <- rmarkdown::render(fn_in, output_file = fn_out, quiet = FALSE)
  "Report {fn_out} copied to inst/reports." %>%
    glue::glue() %>%
    wastdr::wastdr_msg_success(verbose = verbose)


  fn_in <- here::here("vignettes/w2_geolocation_qa.Rmd")
  fn_out <- here::here("inst/reports/w2_geolocation_qa.html")
  "Rendering geolocation qa report to {fn_out}..." %>%
    glue::glue() %>%
    wastdr::wastdr_msg_info(verbose = verbose)
  geolocation_qa_report <- rmarkdown::render(
    fn_in,
    output_file = fn_out,
    quiet = FALSE,
    params = list(w2_data = w2_data)
  )
}
