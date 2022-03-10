#' Generate QA report for surveys and sites
#'
#' @export
#' @examples
#' \dontrun{
#' generate_qa_sites_report(odkc_ex, odkc_tf, wastd_data_yr)
#' }
generate_qa_sites_report <- function(odkc_ex, odkc_tf, year) {
  wastdr::wastdr_msg_info(glue::glue("Rendering QA for sites in {year}..."))
  fn_out <- here::here("vignettes", glue::glue("qa_sites{year}.html"))
  fn_in <- here::here("vignettes", "qa_sites.Rmd")
  site_qa_report <- rmarkdown::render(fn_in, output_file = fn_out, quiet = FALSE)
  wastdr::wastdr_msg_success(glue::glue("Report {fn_out} copied to inst/reports."))
  fs::file_copy(fn_out, here::here("inst/reports/"), overwrite = TRUE)
}
