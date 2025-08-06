# Load necessary libraries
library(bayesplot)
library(shinystan)

# Load the Bayesian model
bayes_model <- readRDS("modeling/bayesian_model.rds")

# Launch_shinystan for interactive diagnostics
launch_shinystan(bayes_model)

# Posterior predictive check
pp_check(bayes_model, ndraws = 100)
ggsave("modeling/diagnostics/pp_checks.png")