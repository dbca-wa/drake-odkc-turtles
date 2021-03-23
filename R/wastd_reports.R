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
#'
#' drake::loadd("wastd_data")
#' }
wastd_reports <- function() {
  drake::drake_plan(
    wastd_data = wastdr::download_wastd_turtledata(),
    wastd_reports = etlTurtleNesting::generate_wastd_reports(wastd_data),
    wastd_tags = etlTurtleNesting::update_tagexplorer(wastd_data)
    # Generate reports and products
    # Upload output to CKAN
    # Upload output to Azure storage https://github.com/Azure/AzureStor
)
}
