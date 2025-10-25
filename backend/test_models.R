# Test script to verify model access
library(text)
library(dplyr)

# Initialize text package
textrpp_initialize()

# Test sentence
test_sentence <- "I worked hard to achieve my goals."

print("Testing model access...")
print(paste("Test sentence:", test_sentence))

# Test Power model
print("Testing Power model...")
tryCatch(
    {
        power_result <- textAssess(
            model_info = "implicitpower_roberta23_nilsson2024",
            texts = test_sentence
        )
        print(paste("Power result:", as.numeric(power_result$.pred_1)))
    },
    error = function(e) {
        print(paste("Power model error:", e$message))
    }
)

# Test Achievement model
print("Testing Achievement model...")
tryCatch(
    {
        achievement_result <- textAssess(
            model_info = "implicitachievement_roberta23_nilsson2024",
            texts = test_sentence
        )
        print(paste("Achievement result:", as.numeric(achievement_result$.pred_1)))
    },
    error = function(e) {
        print(paste("Achievement model error:", e$message))
    }
)

# Test Affiliation model
print("Testing Affiliation model...")
tryCatch(
    {
        affiliation_result <- textAssess(
            model_info = "implicitaffiliation_roberta23_nilsson2024",
            texts = test_sentence
        )
        print(paste("Affiliation result:", as.numeric(affiliation_result$.pred_1)))
    },
    error = function(e) {
        print(paste("Affiliation model error:", e$message))
    }
)

print("Model test completed!")

