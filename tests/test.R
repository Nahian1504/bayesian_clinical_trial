# Load libraries
library(ggplot2)
library(caret)
library(brms)       # or rstanarm if you used it

# Load test data
test_data <- read.csv("data/test_data.csv")

# Convert diagnosis to numeric (M = 1, B = 0)
if (is.character(test_data$diagnosis) || is.factor(test_data$diagnosis)) {
  test_data$diagnosis <- ifelse(test_data$diagnosis == "M", 1, 0)
}

# Store actual values as factor
actual <- factor(test_data$diagnosis, levels = c(0, 1))

# Prepare newdata without the response
predict_data <- test_data[, !(names(test_data) %in% c("diagnosis"))]

# Load models
bayes_model <- readRDS("E:/bayesian_clinical_trial/modeling/bayesian_model.rds")
freq_model  <- readRDS("E:/bayesian_clinical_trial/modeling/frequentist_model.rds")

# Predict using Bayesian model
# Use 'type = "response"' for probabilities in brms/rstanarm
bayes_probs <- predict(bayes_model, newdata = predict_data, summary = TRUE)[, "Estimate"]
bayes_pred  <- ifelse(bayes_probs > 0.5, 1, 0)
bayes_pred  <- factor(bayes_pred, levels = c(0, 1))

# Predict using frequentist model
freq_pred <- predict(freq_model, newdata = predict_data)
if (is.numeric(freq_pred)) freq_pred <- round(freq_pred)
freq_pred <- factor(freq_pred, levels = c(0, 1))

# Debug lengths
cat("Length of actual: ", length(actual), "\n")
cat("Length of bayes_pred: ", length(bayes_pred), "\n")
cat("Length of freq_pred: ", length(freq_pred), "\n")

# Confusion matrices
bayes_confusion <- confusionMatrix(bayes_pred, actual)
freq_confusion  <- confusionMatrix(freq_pred, actual)

# Print performance
print(bayes_confusion)
print(freq_confusion)

# Accuracy comparison plot
results <- data.frame(
  Model = c("Bayesian", "Frequentist"),
  Accuracy = c(
    bayes_confusion$overall["Accuracy"],
    freq_confusion$overall["Accuracy"]
  )
)

accuracy_plot <- ggplot(results, aes(x = Model, y = Accuracy, fill = Model)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Model Accuracy Comparison", x = "Model", y = "Accuracy")

# Display the plot
print(accuracy_plot)

# Save the plot as PNG
ggsave("E:/bayesian_clinical_trial/tests/accuracy_plot.png", 
       plot = accuracy_plot, width = 6, height = 4, dpi = 300)