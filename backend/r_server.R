library(plumber)
library(jsonlite)

# Load your R model here
# model <- readRDS("path/to/your/model.rds")

# Function to predict motives using your R model
predict_motives <- function(text) {
  # Replace this with your actual model prediction code
  # Example:
  # prediction <- predict(model, text)
  
  # For now, returning dummy values
  # You'll need to replace this with your actual model logic
  result <- list(
    achievement = runif(1, 0, 1) * 100,
    affiliation = runif(1, 0, 1) * 100,
    power = runif(1, 0, 1) * 100
  )
  
  # Normalize to sum to 100%
  total <- result$achievement + result$affiliation + result$power
  if (total > 0) {
    result$achievement <- result$achievement / total * 100
    result$affiliation <- result$affiliation / total * 100
    result$power <- result$power / total * 100
  }
  
  return(result)
}

# API endpoint
#* @post /predict
#* @param text:string
function(text) {
  tryCatch({
    result <- predict_motives(text)
    return(result)
  }, error = function(e) {
    return(list(error = e$message))
  })
}

# Health check endpoint
#* @get /health
function() {
  return(list(status = "ok"))
} 