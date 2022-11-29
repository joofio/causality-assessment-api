library(plumber)
# logging
library(logger)



# Specify how logs are written
log_dir <- "logs"
if (!fs::dir_exists(log_dir)) fs::dir_create(log_dir)
log_appender(appender_tee(tempfile("plumber_", log_dir, ".log")))

port <- 8000
server <- plumb("/app/plumber.R")
server$run(host="0.0.0.0",port= as.numeric(port))