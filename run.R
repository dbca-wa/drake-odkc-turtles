library(etlTurtleNesting)
library(wastdr)
library(drake)
library(ruODK)

# After a failed run, unlock the cache
# drake::drake_cache(here::here(".drake"))$unlock()

# Overwrite new records after importing new users or adding aliases
Sys.setenv(ODKC_IMPORT_UPDATE_EXISTING=TRUE)
#
# Else skip unchanged records
# Sys.setenv(ODKC_IMPORT_UPDATE_EXISTING=FALSE)

Sys.setenv(ODKC_IMPORT_UPLOAD_MEDIA=TRUE)
Sys.setenv(RU_VERBOSE=FALSE)
Sys.setenv(WASTDR_VERBOSE=FALSE)

# Old Central instance odkcentral.dbca.wa.gov.au
# will be sunset after 2020-21 season
drake::clean()
drake::make(odkc2019(), lock_envir = FALSE)

# New ODK Central instance odkc.dbca.wa.gov.au
drake::clean()
drake::make(odkc2020(), lock_envir = FALSE)

# Generate reports
drake::make(etlTurtleNesting::wastd_reports())
