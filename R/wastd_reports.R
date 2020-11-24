#' Generate and disseminate WAStD reports
#'
#' @export
#' @examples
#' \dontrun{
#' library(etlTurtleNesting)
#' library(wastdr)
#' library(drake)
#' drake::clean("wastd_reports")
#' drake::make(etlTurtleNesting::wastd_reports(), lock_envir = FALSE)
#' }
wastd_reports <- function() {
  drake::drake_plan(
    wastd_data = wastdr::download_wastd_turtledata(),
    wastd_reports = generate_wastd_reports(wastd_data)
    # Generate reports and products
    # Upload output to CKAN
    # Upload output to Azure storage https://github.com/Azure/AzureStor
)
}
