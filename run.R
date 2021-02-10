library(etlTurtleNesting)
library(wastdr)
library(drake)
library(ruODK)

# drake::drake_cache(here::here(".drake"))$unlock()

Sys.setenv(ODKC_IMPORT_UPDATE_EXISTING=FALSE)
Sys.setenv(ODKC_IMPORT_UPDATE_MEDIA=TRUE)
Sys.setenv(RU_VERBOSE=FALSE)
Sys.setenv(WASTDR_VERBOSE=FALSE)
drake::clean()
drake::make(odkc2019(), lock_envir = FALSE)

# Overwrite new records after importing new users into WAStD
Sys.setenv(ODKC_IMPORT_UPDATE_EXISTING=FALSE)
drake::clean()
drake::make(odkc2020(), lock_envir = FALSE)

# Generate reports
drake::make(etlTurtleNesting::wastd_reports())
