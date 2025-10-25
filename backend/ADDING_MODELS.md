# Adding New Models

This document explains how to add new implicit motive models to the system.

## Current Infrastructure

The system now has a flexible infrastructure that makes it easy to add new models:

### 1. Model Configuration (backend/r_server.R)

Models are defined in the `MODEL_CONFIG` list at the top of `r_server.R`:

```r
MODEL_CONFIG <- list(
  achievement = list(
    model_id = "implicitachievement_roberta_ft_nilsson2024",
    name = "Achievement",
    icon = "🎯",
    color = "#28a745",
    description = "Drive to excel, accomplish, and master challenges"
  ),
  # Add new models here...
)
```

### 2. Adding a New Model

To add a new model, simply add a new entry to the `MODEL_CONFIG` list:

```r
MODEL_CONFIG <- list(
  achievement = list(...),
  affiliation = list(...),
  power = list(...),
  # NEW MODEL
  curiosity = list(
    model_id = "implicitcuriosity_roberta_ft_nilsson2024",
    name = "Curiosity",
    icon = "🔍",
    color = "#ffc107",
    description = "Desire to explore, learn, and discover new things"
  )
)
```

### 3. Update Interpretation Function

Add interpretation logic for the new model in the `get_interpretation` function:

```r
explanations <- list(
  achievement = list(...),
  affiliation = list(...),
  power = list(...),
  # NEW MODEL
  curiosity = list(
    low = "You tend to focus less on exploration and discovery.",
    average = "You have a balanced approach to learning and exploration.",
    high = "You are strongly motivated by exploration and discovery."
  )
)
```

### 4. Frontend Updates

The frontend will automatically work with new models, but you may want to:

1. Update the results display to show the new motive
2. Add appropriate styling for the new color/icon
3. Update any hardcoded motive references

### 5. Model Files

Ensure your new model file (e.g., `textPredict_curiosity.RDS`) is available in the backend directory.

## API Endpoints

- `GET /models` - Returns all available models and their configuration
- `POST /analyze` - Analyzes text using all configured models
- `GET /health` - Health check

## Benefits of This Approach

1. **Easy to add**: Just add one entry to the config
2. **Consistent**: All models follow the same structure
3. **Flexible**: Models can have different icons, colors, and descriptions
4. **Maintainable**: Centralized configuration makes updates easy
5. **Extensible**: Frontend can dynamically adapt to new models

## Example: Adding a "Security" Motive

```r
MODEL_CONFIG <- list(
  achievement = list(...),
  affiliation = list(...),
  power = list(...),
  security = list(
    model_id = "implicitsecurity_roberta_ft_nilsson2024",
    name = "Security",
    icon = "🛡️",
    color = "#6f42c1",
    description = "Need for safety, stability, and protection"
  )
)
```

The system will automatically:

- Load the security model
- Process it with all other models
- Return results including security scores
- Provide interpretations for security motive

