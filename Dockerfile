FROM rocker/r-ver:3

# copy model and scoring script
RUN mkdir /app
COPY app/* /app/
RUN Rscript /app/packages.R 

#RUN mkdir /data/models
#COPY models /data/models
#COPY chedvServer.R /data
#COPY utils.R /data
#COPY runServer.R /data
WORKDIR /app


EXPOSE 8000
ENTRYPOINT ["Rscript", "app.R"]