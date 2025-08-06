# Load necessary libraries

library(tidyverse)

library(janitor)  # Load the janitor package for cleaning column names


# Load the cleaned data

df_clean <- read_csv("data/train_data.csv") %>%  # Load the preprocessed training data
  
  clean_names() %>%
  
  filter(!is.na(diagnosis)) %>%
  
  mutate(diagnosis = ifelse(diagnosis == "M", 1, 0))  # Convert diagnosis to binary


# Fit the frequentist model

freq_model <- glm(diagnosis ~ radius_mean + texture_mean + perimeter_mean + area_mean + 
                    
                    smoothness_mean + compactness_mean + concavity_mean + 
                    
                    concave_points_mean + symmetry_mean + fractal_dimension_mean, 
                  
                  data = df_clean, family = binomial)


# Display the summary of the model

model_summary <- summary(freq_model)

# Save the summary to a text file

capture.output(model_summary, file = "reporting/frequentist_model_summary.txt")


# Save the model

saveRDS(freq_model, "modeling/frequentist_model.rds")