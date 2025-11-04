FROM rocker/r-ver:4.5.1

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
 && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
  #  graphviz \
  #  libgraphviz-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
 #   make \
 #   g++ \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY app/ ./

RUN Rscript packages.R

EXPOSE 8000
ENTRYPOINT ["Rscript", "app.R"]
