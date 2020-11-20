#'Generate reports from WAStD turtle data
#'
#' @export
#' @examples
#' \dontrun{
#' drake::loadd("wastd_data")
#' rmarkdown::render(
#' here::here("vignettes/wastd.Rmd"),
#' params = list(area_name = "Delambre Island"),
#' output_file = here::here("vignettes/wastd_del.html"))
#' }
generate_wastd_reports <- function(wastd_data){
  for (a in unique(wastd_data$areas$area_name)) {
    fn <- here::here("vignettes", glue::glue("{wastdr::urlize(a)}.html"))
    wastdr::wastdr_msg_info(glue::glue("Rendering report for {a} to {fn}..."))
    rmarkdown::render(
      here::here("vignettes/wastd.Rmd"),
      params = list(area_name = a),
      output_file = fn
    )

    wastdr::wastdr_msg_success(glue::glue("Compiled {fn}."))
  }

  fs::dir_ls(here::here("vignettes"), glob = "*.html") %>%
    fs::file_copy(here::here("inst/reports/"), overwrite = TRUE)
  wastdr::wastdr_msg_success("Copied reports to inst/reports.")

  fs::dir_ls(here::here("inst/reports/"), glob = "*.html")
}
