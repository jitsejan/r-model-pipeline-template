FROM r-base
MAINTAINER Jitse-Jan van Waterschoot <j.waterschoot@marketinvoice.com>
RUN R -e 'install.packages(c("randomForest", "plumber"), repos="http://cran.us.r-project.org", dependencies=TRUE)'

# Add a non-root user who will launch the apps
RUN useradd plumber \
	&& mkdir /home/plumber \
	&& chown plumber:plumber /home/plumber \
	&& addgroup plumber staff

USER plumber
# Copy files
COPY scripts/expose.R /opt/scripts/
COPY scripts/plumber.R /opt/scripts/
COPY models/rf_model.Rds /opt/models/
# Serve
CMD ["Rscript", "/opt/scripts/plumber.R"]