# Load necessary libraries

library(brms)

library(bayesplot)  # For plotting Bayesian model results

library(tidyverse)  # For data manipulation and plotting


# Load the Bayesian model

bayes_model <- readRDS("modeling/bayesian_model.rds")


# Sensitivity analysis for prior robustness

prior_checks <- function(prior) {
  
  
  
  model <- brm(diagnosis ~ radius_mean + texture_mean + perimeter_mean + area_mean + 
                 
                 smoothness_mean + compactness_mean + concavity_mean + 
                 
                 concave_points_mean + symmetry_mean + fractal_dimension_mean, 
               
               data = df_clean, 
               
               family = bernoulli(),
               
               prior = prior,
               
               chains = 4, cores = 4, seed = 42)
  
  
  
  return(model)  # Return the model object for further analysis
  
}


# Example usage

model_result <- prior_checks(prior = prior(normal(0, 1), class = "b"))


# Extract posterior samples

posterior_samples <- as.data.frame(model_result)


# Create a plot of the posterior distributions for the coefficients

posterior_plot <- mcmc_areas(posterior_samples, 
                             
                             pars = c("b_radius_mean", "b_texture_mean", "b_perimeter_mean", 
                                      
                                      "b_area_mean", "b_smoothness_mean", "b_compactness_mean", 
                                      
                                      "b_concavity_mean", "b_concave_points_mean", 
                                      
                                      "b_symmetry_mean", "b_fractal_dimension_mean"),
                             
                             prob = 0.95) +  # 95% credible intervals
  
  labs(title = "Posterior Distributions of Coefficients",
       
       x = "Coefficient Value",
       
       y = "Parameter") +
  
  theme_minimal()


# Save the plot

ggsave("modeling/sensitivity_analysis/sensitivity_analysis_plot.png", plot = posterior_plot)


# Display the plot

print(posterior_plot)