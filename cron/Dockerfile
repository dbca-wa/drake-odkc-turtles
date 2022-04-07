FROM rocker/geospatial:4.1.2 as base
RUN apt-get update && apt-get install -y cron freetds-common freetds-dev \
libbibutils6 libct4 libgeos++-dev libghc-pandoc-citeproc-data libprotoc-dev \
libsybdb5 libyaml-0-2 pandoc pandoc-citeproc pandoc-data tdsodbc &&\
rm -rf /var/lib/apt/lists/*

FROM base as rlibs
RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 4)" >> /usr/local/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'
# Already provided through rocker/geospatial row.names(installed.packages()):
#RUN Rscript -e 'remotes::install_version("glue",upgrade="never", version = "1.6.2")'
#RUN Rscript -e 'remotes::install_version("DBI",upgrade="never", version = "1.1.2")'
#RUN Rscript -e 'remotes::install_version("dplyr",upgrade="never", version = "1.0.8")'
#RUN Rscript -e 'remotes::install_version("fs",upgrade="never", version = "1.5.2")'
#RUN Rscript -e 'remotes::install_version("shiny",upgrade="never", version = "1.7.1")'
#RUN Rscript -e 'remotes::install_version("geojsonsf",upgrade="never", version = "2.0.1")'
#RUN Rscript -e 'remotes::install_version("leaflet",upgrade="never", version = "2.1.0")'
#RUN Rscript -e 'remotes::install_version("tidyr",upgrade="never", version = "1.2.0")'
#RUN Rscript -e 'remotes::install_version("lubridate",upgrade="never", version = "1.8.0")'
#RUN Rscript -e 'remotes::install_version("testthat",upgrade="never", version = "3.1.2")'
#RUN Rscript -e 'remotes::install_version("spelling",upgrade="never", version = "2.2")'
#RUN Rscript -e 'remotes::install_github("r-spatial/sf")'
#RUN Rscript -e 'remotes::install_version("scales",upgrade="never", version = "1.1.1")'
# turtleviewer2/wastdr renv::dependencies() not provided through rocker/geospatial:
RUN Rscript -e 'remotes::install_version("config",upgrade="never", version = "0.3.1")'
RUN Rscript -e 'remotes::install_version("clisymbols",upgrade="never", version = "1.2.0")'
RUN Rscript -e 'remotes::install_version("geojsonio",upgrade="never", version = "0.9.4")'
RUN Rscript -e 'remotes::install_version("here",upgrade="never", version = "1.0.1")'
RUN Rscript -e 'remotes::install_version("janitor",upgrade="never", version = "2.1.0")'
RUN Rscript -e 'remotes::install_version("leaflet.extras",upgrade="never", version = "1.0.0")'
RUN Rscript -e 'remotes::install_version("odbc",upgrade="never", version = "1.3.3")'
RUN Rscript -e 'remotes::install_version("reactable",upgrade="never", version = "0.2.3")'
RUN Rscript -e 'remotes::install_version("waiter",upgrade="never", version = "0.2.5")'
RUN Rscript -e 'remotes::install_version("drake",upgrade="never", version = "7.13.3")'
RUN Rscript -e 'remotes::install_version("fuzzyjoin",upgrade="never", version = "0.1.6")'
RUN Rscript -e 'remotes::install_version("pointblank",upgrade="never", version = "0.10.0")'
RUN Rscript -e 'remotes::install_version("waiter",upgrade="never", version = "0.2.5")'
RUN Rscript -e 'remotes::install_version("plotly",upgrade="never", version = "4.10.0")'
RUN Rscript -e 'remotes::install_version("shinyWidgets",upgrade="never", version = "0.6.4")'
RUN Rscript -e 'remotes::install_github("Thinkr-open/golem")'
RUN Rscript -e 'remotes::install_github("RinteRface/bs4Dash")'
# Unused wastdr dependencies:
# RODBC ckanr leaftime geojsonlint ggalt ggTimeSeries listviewer
RUN Rscript -e 'remotes::install_github("ropensci/ruODK", upgrade = "never")'
RUN Rscript -e 'remotes::install_github("dbca-wa/wastdr", upgrade = "never")'

FROM rlibs
RUN mkdir /app
ADD . /app
WORKDIR /app
RUN R -e 'remotes::install_local(upgrade="never", dependencies = FALSE) '

# Mount a volume to /app/inst that is shared with turtleviewer2
# A second volume /app/config will hold an .Renviron file (replace with a vol mount)
RUN mkdir -p /app/inst /app/config && echo "WASTDR_API_URL=NOTSET" >> /app/config/.Renviron

# Initiate cronjob
RUN crontab cron/cronjob

# Run command on container startup
CMD echo "start cronjob" &&\
  (cron) &&\
  echo "init logs" &&\
  touch /app/inst/cron.log &&\
  tail -f /app/inst/cron.log
