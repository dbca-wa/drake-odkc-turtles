library(etlTurtleNesting)
library(wastdr)
library(drake)

# Overwrite new records after importing new users into WAStD
# Sys.setenv(ODKC_IMPORT_UPDATE_EXISTING=TRUE)
Sys.setenv(ODKC_IMPORT_UPDATE_EXISTING=FALSE)

drake::clean()
drake::make(odkc2019())
drake::clean()
drake::make(odkc2020())
