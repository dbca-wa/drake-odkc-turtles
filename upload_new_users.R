# Append new users to spreadsheet: username, name, email, phone, role
#
# Actions on spreadsheet:
# Open with option "quoted columns as text"
# username (A), name (B), email, phone, role (C-E)
# Formula for
# =SUBSTITUTE(LOWER(B2), " ", "_")
# Format phone as text and prepend with +61
# Save as CSV with "quote all text columns"
library(wastdr)
users <- here::here(
  # "data/users_thv2020.csv"
  "data/users_broome2020.csv"
  ) %>%
  readr::read_csv(col_types = "ccccc")

user_resp <- users %>%
  wastdr::wastd_bulk_post("users",
                          verbose = TRUE
                          # api_url = Sys.getenv("WASTDR_API_DEV_URL"),
                          # api_token = Sys.getenv("WASTDR_API_DEV_TOKEN")
  )
