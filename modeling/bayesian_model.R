# Load necessary libraries

library(readr)  # For read_csv

library(dplyr)  # For data manipulation

library(janitor)  # For clean_names

library(brms)  # For Bayesian modeling


# Load the cleaned data

df_clean <- read_csv("data/train_data.csv") %>%
  
  clean_names() %>%
  
  filter(!is.na(diagnosis)) %>%
  
  mutate(diagnosis = ifelse(diagnosis == "M", 1, 0))  # Convert diagnosis to binary


# Fit the Bayesian model

bayes_model <- brm(
  
  diagnosis ~ radius_mean + texture_mean + perimeter_mean + area_mean + 
    
    smoothness_mean + compactness_mean + concavity_mean + 
    
    concave_points_mean + symmetry_mean + fractal_dimension_mean, 
  
  data = df_clean, 
  
  family = bernoulli(),
  
  chains = 4, 
  
  cores = 4, 
  
  seed = 42
  
)


# Display the summary of the model

model_summary <- summary(bayes_model)


# Save the summary to a text file

capture.output(model_summary, file = "reporting/bayesian_model_summary.txt")


# Save the Bayesian model

saveRDS(bayes_model, "modeling/bayesian_model.rds")