FROM rstudio/plumber
RUN R -e 'install.packages(c("plumber", "dplyr", "lubridate","forecast","logger","fs","tictoc","jsonlite"))'

# copy model and scoring script
RUN mkdir /app
COPY app/* /app/
#RUN mkdir /data/models
#COPY models /data/models
#COPY chedvServer.R /data
#COPY utils.R /data
#COPY runServer.R /data
WORKDIR /app


EXPOSE 8000
ENTRYPOINT ["Rscript", "runServer.R", "chedvServer.R"]