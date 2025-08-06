# Bayesian Adaptive Design Methods

# Includes functions for:

# - Early stopping rules

# - Adaptive randomization

# - Interim analysis

# - Visualization


library(brms)

library(bayesplot)

library(tidyverse)

library(gridExtra)


# Configuration parameters

CONFIG <- list(
  
  efficacy_threshold = 0.95,  # Probability threshold for efficacy
  
  futility_threshold = 0.1,   # Probability threshold for futility
  
  max_sample_size = 200,      # Maximum sample size
  
  interim_frequency = 20,     # Perform interim analysis every N patients
  
  randomization_ratio = c(1,1) # Initial randomization ratio
  
)


# Early stopping function

early_stopping <- function(model_fit, threshold_type = "efficacy") {
  
  # Check if trial should stop early based on posterior probabilities
  
  posterior_samples <- as.matrix(model_fit)
  
  
  
  # For binary outcomes (probability of success)
  
  p_success <- mean(posterior_samples[, "b_Intercept"] > 0)
  
  
  
  if (threshold_type == "efficacy") {
    
    return(p_success > CONFIG$efficacy_threshold)
    
  } else {
    
    return(p_success < CONFIG$futility_threshold)
    
  }
  
}


# Adaptive randomization function

adaptive_randomization <- function(current_data, model_fit) {
  
  # Get posterior probabilities for each treatment arm
  
  post_prob <- posterior_epred(model_fit, newdata = current_data)
  
  
  
  # Update randomization ratios based on posterior probabilities
  
  arm_probs <- colMeans(post_prob)
  
  new_ratio <- arm_probs / sum(arm_probs)
  
  
  
  return(new_ratio)
  
}


# Interim analysis function

interim_analysis <- function(current_data, model_formula) {
  
  # Fit Bayesian model to current data
  
  model_fit <- brm(
    
    formula = model_formula,
    
    data = current_data,
    
    family = bernoulli(),
    
    prior = prior(normal(0, 1.5), class = "b"),
    
    cores = 4,
    
    seed = 42,
    
    refresh = 0  # Suppress output
    
  )
  
  
  
  # Check stopping rules
  
  stop_efficacy <- early_stopping(model_fit, "efficacy")
  
  stop_futility <- early_stopping(model_fit, "futility")
  
  
  
  # Update randomization if continuing
  
  if (!stop_efficacy & !stop_futility) {
    
    new_ratio <- adaptive_randomization(current_data, model_fit)
    
    CONFIG$randomization_ratio <<- new_ratio
    
  }
  
  
  
  return(list(
    
    model = model_fit,
    
    stop_efficacy = stop_efficacy,
    
    stop_futility = stop_futility,
    
    randomization_ratio = CONFIG$randomization_ratio
    
  ))
  
}


# Plotting functions

plot_interim_results <- function(model_fit) {
  
  # Posterior distributions
  
  p1 <- mcmc_intervals(model_fit, pars = vars(starts_with("b_"))) +
    
    ggtitle("Posterior Distributions of Effects")
  
  
  
  # Trace plots for convergence
  
  p2 <- mcmc_trace(model_fit, pars = vars(starts_with("b_"))) +
    
    ggtitle("Trace Plots")
  
  
  
  # Combine plots
  
  grid.arrange(p1, p2, ncol = 1)
  
}


# Main simulation function

bayesian_adaptive_trial <- function(data, model_formula) {
  
  results <- list()
  
  
  
  for (i in seq(0, CONFIG$max_sample_size, by = CONFIG$interim_frequency)) {
    
    if (i == 0) next  # Skip 0
    
    
    
    current_data <- data[1:i, ]
    
    
    
    cat("\nPerforming interim analysis at n =", i, "\n")
    
    
    
    # Run interim analysis
    
    int_analysis <- interim_analysis(current_data, model_formula)
    
    
    
    # Save results
    
    results[[as.character(i)]] <- int_analysis
    
    
    
    # Plot results
    
    p <- plot_interim_results(int_analysis$model)
    
    print(p)
    
    
    
    # Check stopping criteria
    
    if (int_analysis$stop_efficacy) {
      
      cat("\nStopping early for efficacy at n =", i)
      
      break
      
    }
    
    if (int_analysis$stop_futility) {
      
      cat("\nStopping early for futility at n =", i)
      
      break
      
    }
    
    
    
    # Show updated randomization ratio
    
    cat("\nUpdated randomization ratio:", int_analysis$randomization_ratio, "\n")
    
  }
  
  
  
  return(results)
  
}


# EXAMPLE USAGE -----------------------------------------------------------


# Below is example code showing how to use the adaptive trial functions.

# This can be run interactively or included as documentation in the file.


# 1. Define the model formula for your study

#    - Adjust terms according to your actual study design

#    - Example for a binary outcome with treatment effect:

# model_formula <- bf(

#   response ~ treatment + covariate1 + covariate2 + (1 | subject),

#   family = bernoulli()

# )


# 2. Load your clinical trial data

#    - Should include columns for outcome, treatment, and any covariates

# clinical_data <- read.csv("trial_data.csv")


# 3. Configure trial parameters (modify in CONFIG list if needed)

#    - Set thresholds, sample sizes, etc.

# CONFIG$efficacy_threshold <- 0.975  # More stringent threshold

# CONFIG$max_sample_size <- 300       # Increase maximum sample


# 4. Run the adaptive trial

# trial_results <- bayesian_adaptive_trial(

#   data = clinical_data,

#   model_formula = model_formula

# )


# 5. View final results

# summary(trial_results[[length(trial_results)]]$model)

# plot_interim_results(trial_results[[length(trial_results)]]$model)


# Run adaptive trial

# results <- bayesian_adaptive_trial(data, model_formula)
