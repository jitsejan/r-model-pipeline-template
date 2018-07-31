FROM r-base
MAINTAINER Jitse-Jan van Waterschoot <j.waterschoot@marketinvoice.com>
RUN R -e 'install.packages(c("randomForest", "plumber"), repos="http://cran.us.r-project.org", dependencies=TRUE)'

# Add a non-root user who will launch the apps
RUN useradd plumber \
	&& mkdir /home/plumber \
	&& chown plumber:plumber /home/plumber \
	&& addgroup plumber staff

COPY scripts/expose.R /app/expose.R
COPY scripts/plumber.R /app/plumber.R
COPY models/rf_model.Rds /app/rf_model.Rds

RUN chmod 700 /app/plumber.R && chgrp -R staff /app

# Plumb your app into 8000
EXPOSE 8000

# CMD ["/app/plumber.R"]
