library(etlTurtleNesting)
library(wastdr)
library(drake)
library(ruODK)
library(googlesheets4)

# drake::drake_cache(here::here(".drake"))$unlock() # Recover failed run
#
# Sys.setenv(ODKC_IMPORT_UPDATE_EXISTING=TRUE)        # After adding user aliases
Sys.setenv(ODKC_IMPORT_UPDATE_EXISTING=FALSE)     # Speedrun

Sys.setenv(ODKC_IMPORT_UPLOAD_MEDIA=TRUE)
Sys.setenv(RU_VERBOSE=FALSE)
Sys.setenv(WASTDR_VERBOSE=FALSE)

drake::clean()
drake::make(odkc2019(), lock_envir = FALSE)         # Sunset after 2020-21
drake::make(odkc2020(), lock_envir = FALSE)

# drake::clean("wastd_data")
# drake::clean("wastd_tags")
# drake::clean("wastd_reports")
drake::make(etlTurtleNesting::wastd_reports())
