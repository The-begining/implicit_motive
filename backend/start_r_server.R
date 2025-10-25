# Start the R plumber server
library(plumber)

# Set working directory to the backend folder
setwd(".")

# Start the server
pr <- plumb("r_server.R")
pr$run(port = 8001, host = "0.0.0.0")

