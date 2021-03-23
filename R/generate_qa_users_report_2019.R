#' Generate QA report for user mapping
#'
#' @export
#' @examples
#' \dontrun{
#' generate_qa_users_report_2019(odkc_ex, user_mapping, wastd_data_yr)
#' }
generate_qa_users_report_2019 <- function(odkc_ex, user_mapping, year){
  wastdr::wastdr_msg_info(glue::glue("Rendering QA for users in {year}..."))
  fn <- here::here("vignettes", glue::glue("qa_users{year}.html"))
  site_qa  = rmarkdown::render(
    knitr_in("vignettes/qa_users_2019.Rmd"),
    output_file = fn,
    quiet=FALSE
  )
  wastdr::wastdr_msg_success(glue::glue("Report {fn} copied to inst/reports."))
  fs::file_copy(fn, here::here("inst/reports/"), overwrite = TRUE)
}
