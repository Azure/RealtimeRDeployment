FROM trestletech/plumber

# install the randomForest package
RUN R -e 'install.packages(c("randomForest"))'

# copy model and scoring script
RUN mkdir /data
COPY data/service.R /data
COPY data/model.rds /data
WORKDIR /data

# plumb and run server
EXPOSE 8000
ENTRYPOINT ["R", "-e", \
    "pr <- plumber::plumb('/data/service.R'); pr$run(host='0.0.0.0', port=8000)"]
