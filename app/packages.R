if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
BiocManager::install(c("graph", "RBGL", "Rgraphviz"))

install.packages(c("plumber", "dplyr", "logger", "jsonlite", "yaml", "fs", "gRain"))
