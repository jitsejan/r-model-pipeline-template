FROM r-base
# Model dependencies
RUN echo 'install.packages(c("randomForest"), repos="http://cran.us.r-project.org", dependencies=TRUE)' > /tmp/packages.R \
    && Rscript /tmp/packages.R
# Plumber dependencies
RUN apt-get update -qq && apt-get install -y \
  git-core \
  libssl-dev \
  libcurl4-gnutls-dev

RUN R -e 'install.packages(c("devtools"))'
RUN R -e 'devtools::install_github("trestletech/plumber")'

EXPOSE 8000
CMD ["R"]