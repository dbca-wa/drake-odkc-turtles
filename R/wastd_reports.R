#' Generate and disseminate WAStD reports
#'
#' Writing to Google Sheets requires a Google Service Account Token to be
#' present at `~/.config/gcloud/application_default_credentials.json`.
#'
#' @seealso https://gargle.r-lib.org/articles/how-gargle-gets-tokens.html#credentials_app_default
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
  # options(gargle_oauth_cache = "~/.config/secrets",
  #         gargle_oauth_email = Sys.getenv("GOOGLE_EMAIL"),
  #         gargle_verbosity = "debug")
  drake::drake_plan(
    wastd_data = wastdr::download_wastd_turtledata(),
    wastd_reports = etlTurtleNesting::generate_wastd_reports(wastd_data),
    wastd_tags = etlTurtleNesting::update_tagexplorer(wastd_data),
    sharepoint = etlTurtleNesting::upload_to_sharepoint()
)
}
