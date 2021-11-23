#' Generate QA report for user mapping
#'
#' @export
#' @examples
#' \dontrun{
#' generate_qa_users_report(odkc_ex, user_mapping, wastd_data_yr)
#' }
generate_qa_users_report <- function(odkc_ex, user_mapping, year){
  wastdr::wastdr_msg_info(glue::glue("Rendering QA for users in {year}..."))
  fn_out <- here::here("vignettes", glue::glue("qa_users{year}.html"))
  fn_in <- here::here("vignettes", "qa_users.Rmd")
  user_qa_report  = rmarkdown::render(fn_in, output_file = fn_out, quiet=FALSE)
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
generate_qa_users_report_w2 <- function(
  user_mapping, w2_yr, w2_data, verbose = wastdr::get_wastdr_verbose()){
  "Rendering QA for WAMTRAM users in {w2_yr}..." %>%
    glue::glue() %>% wastdr::wastdr_msg_info(verbose=verbose)
  fn_out <- here::here("vignettes", glue::glue("qa_users_w2{w2_yr}.html"))
  fn_in <- here::here("vignettes", "qa_users_w2.Rmd")
  user_qa_report  = rmarkdown::render(fn_in, output_file = fn_out, quiet=FALSE)
  fs::file_copy(fn_out, here::here("inst/reports/"), overwrite = TRUE)
  "Report {fn_out} copied to inst/reports." %>%
    glue::glue() %>% wastdr::wastdr_msg_success(verbose = verbose)
}

