library(plumber)
library(jsonlite)
library(text)
library(dplyr)

# Only run these once per R session (not on every request)
# text::textrpp_install()
# text::textrpp_initialize(save_profile = TRUE)

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
    print(paste("Input text:", text))

    # Power
    power_assess <- textAssess(
      model_info = "implicitpower_roberta23_nilsson2024",
      texts = text
    )
    print("Power full output:")
    print(power_assess)
    power <- as.numeric(power_assess$.pred_1)
    print(paste("Power .pred_1:", power))

    # Achievement
    achievement_assess <- textAssess(
      model_info = "implicitachievement_roberta23_nilsson2024",
      texts = text
    )
    print("Achievement full output:")
    print(achievement_assess)
    achievement <- as.numeric(achievement_assess$.pred_1)
    print(paste("Achievement .pred_1:", achievement))

    # Affiliation
    affiliation_assess <- textAssess(
      model_info = "implicitaffiliation_roberta23_nilsson2024",
      texts = text
    )
    print("Affiliation full output:")
    print(affiliation_assess)
    affiliation <- as.numeric(affiliation_assess$.pred_1)
    print(paste("Affiliation .pred_1:", affiliation))

    # Handle NA/NaN
    if (is.na(achievement) || is.nan(achievement)) achievement <- 0
    if (is.na(affiliation) || is.nan(affiliation)) affiliation <- 0
    if (is.na(power) || is.nan(power)) power <- 0

    # Normalize to sum to 100%
    total <- achievement + affiliation + power
    print(paste("Total:", total))
    if (total > 0) {
      achievement <- achievement / total * 100
      affiliation <- affiliation / total * 100
      power <- power / total * 100
    } else {
      print("Model could not process the input text.")
      return(list(error = "Model could not process the input text."))
    }

    print(list(
      achievement = achievement,
      affiliation = affiliation,
      power = power
    ))

    return(list(
      achievement = achievement,
      affiliation = affiliation,
      power = power
    ))
  }, error = function(e) {
    print(paste("Error:", e$message))
    return(list(error = e$message))
  })
}

# Health check endpoint
#* @get /health
function() {
  return(list(status = "ok"))
} 