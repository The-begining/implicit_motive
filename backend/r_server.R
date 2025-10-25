library(plumber)
library(jsonlite)
library(text)
library(dplyr)
library(stringr)

# Initialize text package for model access
textrpp_initialize()

# Model configuration - easy to add new models
MODEL_CONFIG <- list(
  achievement = list(
    model_id = "implicitachievement_roberta_ft_nilsson2024",
    name = "Achievement",
    icon = "🎯",
    color = "#28a745",
    description = "Drive to excel, accomplish, and master challenges"
  ),
  affiliation = list(
    model_id = "implicitaffiliation_roberta_ft_nilsson2024",
    name = "Affiliation",
    icon = "💙",
    color = "#17a2b8",
    description = "Desire for connection, belonging, and positive relationships"
  ),
  power = list(
    model_id = "implicitpower_roberta_ft_nilsson2024",
    name = "Power",
    icon = "👑",
    color = "#dc3545",
    description = "Aspiration to influence, lead, and make an impact"
  )
)

# Helper function to process one motive
process_motive <- function(model_id, sentences) {
  # Run predictions for all sentences
  assess <- textAssess(
    model_info = model_id,
    texts = sentences
  )

  # Extract .pred_1 for each sentence
  sentence_probs <- as.numeric(assess$.pred_1)

  # Calculate aggregates
  sum_probs <- sum(sentence_probs, na.rm = TRUE)
  avg_prob <- mean(sentence_probs, na.rm = TRUE)
  perc_story_level <- avg_prob * 100

  return(list(
    sentence_probs = sentence_probs,
    sum_probs = sum_probs,
    avg_prob_story_level = avg_prob,
    percentage_story_level = perc_story_level
  ))
}

# Helper function to get interpretation and percentile
get_interpretation <- function(score, motive_type) {
  # Placeholder percentile calculation (August will provide actual data)
  # For now, using a simple heuristic based on score ranges
  if (score < 0.1) {
    percentile <- "10th"
    interpretation <- "Very low"
  } else if (score < 0.25) {
    percentile <- "25th"
    interpretation <- "Low"
  } else if (score < 0.5) {
    percentile <- "50th"
    interpretation <- "Average"
  } else if (score < 0.75) {
    percentile <- "75th"
    interpretation <- "High"
  } else {
    percentile <- "90th"
    interpretation <- "Very high"
  }

  # Motive-specific explanations
  explanations <- list(
    achievement = list(
      low = "You tend to focus less on personal accomplishments and mastery.",
      average = "You have a balanced approach to achievement and success.",
      high = "You are strongly driven by personal accomplishments and mastery."
    ),
    affiliation = list(
      low = "You tend to focus less on building relationships and connections.",
      average = "You have a balanced approach to social relationships.",
      high = "You are strongly motivated by building relationships and connections."
    ),
    power = list(
      low = "You tend to focus less on influencing others and taking charge.",
      average = "You have a balanced approach to leadership and influence.",
      high = "You are strongly motivated by influencing others and taking charge."
    )
  )

  return(list(
    percentile = percentile,
    interpretation = interpretation,
    explanation = explanations[[motive_type]][[ifelse(score < 0.25, "low", ifelse(score < 0.75, "average", "high"))]]
  ))
}

# API endpoint for implicit motive analysis
#* @post /predict
#* @param text:string
function(text) {
  tryCatch(
    {
      print(paste("Input text:", text))

      # Sentence splitting using simple regex
      sentences <- unlist(strsplit(text, "[.!?]+"))
      sentences <- trimws(sentences)
      sentences <- sentences[sentences != ""]
      total_words <- length(unlist(strsplit(text, "\\s+")))
      print(paste("Total sentences:", length(sentences)))
      print(paste("Total words:", total_words))

      # Process each motive using the model configuration
      results <- list()
      interpretations <- list()

      for (motive_name in names(MODEL_CONFIG)) {
        config <- MODEL_CONFIG[[motive_name]]
        print(paste("Running", config$name, "model..."))

        motive_results <- process_motive(config$model_id, sentences)
        motive_interpretation <- get_interpretation(motive_results$avg_prob_story_level, motive_name)

        results[[motive_name]] <- c(motive_results, motive_interpretation)
      }

      # Return results
      result <- c(
        list(
          sentences = sentences,
          total_words = total_words,
          total_sentences = length(sentences),
          text_length_chars = nchar(text)
        ),
        results
      )

      return(result)
    },
    error = function(e) {
      print(paste("Error:", e$message))
      return(list(error = e$message))
    }
  )
}

# Health check endpoint
#* @get /health
function() {
  return(list(status = "ok"))
}

# Get available models endpoint
#* @get /models
function() {
  return(list(
    models = MODEL_CONFIG,
    count = length(MODEL_CONFIG)
  ))
}
