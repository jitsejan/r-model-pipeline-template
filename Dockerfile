FROM r-base
RUN echo 'install.packages(c("randomForest"), repos="http://cran.us.r-project.org", dependencies=TRUE)' > /tmp/packages.R \
    && Rscript /tmp/packages.R