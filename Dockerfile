FROM rexyai/restrserve

# install the randomForest package
RUN Rscript -e 'install.packages(c("randomForest"))'

# copy model and scoring script
RUN mkdir /data
COPY data/service.R /data
COPY data/model.rds /data
WORKDIR /data

EXPOSE 8000

CMD ["Rscript", "-e", "source('service.R'); backend$start(app, http_port=8000)"]
