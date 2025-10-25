# Fix R dependencies for the implicit motive analyzer
# Run this script first to set up the environment

# Install required packages if not already installed
if (!require(plumber)) install.packages("plumber")
if (!require(jsonlite)) install.packages("jsonlite")
if (!require(dplyr)) install.packages("dplyr")

# Install text package if not already installed
if (!require(text)) {
    install.packages("text")
}

# Initialize text package with proper Python environment
library(text)

# Set up the conda environment for text package
text::textrpp_install()
text::textrpp_initialize(save_profile = TRUE)

cat("R dependencies have been set up successfully!\n")
cat("You can now run the R server.\n")

