# Load necessary libraries

library(tidyverse)

library(gtsummary)

library(broom)  # For tidying model outputs

library(brms)    # For working with brms models


# Load the freq model

freq_model <- readRDS("modeling/frequentist_model.rds")


# Create a tidy summary of the frequentist model

freq_summary <- tidy(freq_model) %>%
  
  mutate(model = "Frequentist")


# Load the Bayesian model

bayes_model <- readRDS("modeling/bayesian_model.rds")


# Create a tidy summary of the Bayesian model

bayes_summary <- posterior_summary(bayes_model) %>%
  
  as.data.frame() %>%
  
  rownames_to_column(var = "term")


# Check the structure of bayes_summary

print(head(bayes_summary))

print(names(bayes_summary))  # Check column names


# Rename columns based on the actual names in bayes_summary

bayes_summary <- bayes_summary %>%
  
  rename(estimate = Estimate, 
         
         std.error = Est.Error, 
         
         conf.low = Q2.5, 
         
         conf.high = Q97.5) %>%  # Adjust these names based on actual output
  
  mutate(model = "Bayesian")


# Combine the summaries

combined_summary <- bind_rows(freq_summary, bayes_summary)


# Create a plot comparing the coefficients of both models

comparison_plot <- ggplot(combined_summary, aes(x = term, y = estimate, color = model)) +
  
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  
  geom_errorbar(aes(ymin = estimate - std.error, ymax = estimate + std.error), 
                
                position = position_dodge(width = 0.5), width = 0.2) +
  
  labs(title = "Comparison of Model Coefficients",
       
       x = "Predictor Variables",
       
       y = "Estimated Coefficients") +
  
  theme_minimal() +
  
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Save the plot

ggsave("modeling/model_comparison_plot.png", plot = comparison_plot)


# Display the plot

print(comparison_plot)