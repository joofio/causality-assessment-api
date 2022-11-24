install.packages(c( "dplyr","logger","jsonlite","yaml","fs","gRain"))

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install(c("graph", "RBGL", "Rgraphviz"))