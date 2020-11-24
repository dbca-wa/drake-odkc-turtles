#' Generate QA report for surveys and sites
#'
#' @export
#' @examples
#' \dontrun{
#' generate_qa_sites_report(odkc_ex, odkc_tf, wastd_data_yr)
#' }
generate_qa_sites_report <- function(odkc_ex, odkc_tf, year){
  wastdr::wastdr_msg_info(glue::glue("Rendering QA for sites in {year}..."))
  fn <- here::here("vignettes", glue::glue("qa_sites{year}.html"))
  site_qa  = rmarkdown::render(
    knitr_in("vignettes/qa_sites.Rmd"),
    output_file = fn,
    quiet=FALSE
  )
  wastdr::wastdr_msg_success(glue::glue("Report {fn} copied to inst/reports."))
  fs::file_copy(fn, here::here("inst/reports/"), overwrite = TRUE)
}
