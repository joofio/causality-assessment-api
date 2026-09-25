options(repos = c(CRAN = "https://cloud.r-project.org"))

if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager", repos = "https://cloud.r-project.org")
}
BiocManager::install(c("graph", "RBGL", "Rgraphviz"), ask = FALSE, update = FALSE)

install.packages(c("plumber", "dplyr", "logger", "jsonlite", "yaml", "fs", "gRain"), repos = "https://cloud.r-project.org")
