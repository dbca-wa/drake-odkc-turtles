library(etlTurtleNesting)
library(wastdr)
library(drake)


Sys.setenv(ODKC_IMPORT_UPDATE_EXISTING=FALSE)
Sys.setenv(ODKC_IMPORT_UPDATE_MEDIA=TRUE)
drake::clean()
drake::make(odkc2019(), lock_envir = FALSE)

# Overwrite new records after importing new users into WAStD
Sys.setenv(ODKC_IMPORT_UPDATE_EXISTING=TRUE)
drake::clean()
drake::make(odkc2020(), lock_envir = FALSE)

# Generate reports
drake::make(etlTurtleNesting::wastd_reports())
