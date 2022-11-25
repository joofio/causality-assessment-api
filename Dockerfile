FROM rocker/r-ver:3

# copy model and scoring script
RUN mkdir /app

COPY app/* /app/
RUN Rscript /app/packages.R 

WORKDIR /app


EXPOSE 8000
ENTRYPOINT ["Rscript", "app.R"]