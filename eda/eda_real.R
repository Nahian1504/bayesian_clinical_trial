# Load necessary libraries

library(tidyverse)  # This loads dplyr, ggplot2, and other tidyverse packages

library(janitor)    # This loads the janitor package for data cleaning functions

library(GGally)     # This loads the GGally package for ggpairs function


# Load the dataset

df <- read_csv("data/real_clinical_trial.csv")


# Check for parsing issues

if (any(problems(df))) {
  
  print("Parsing Issues:")
  
  print(problems(df))
  
}


# Print column names to diagnose the issue

print("Column Names:")

print(colnames(df))


# Remove unnamed columns if necessary

if ("...33" %in% colnames(df)) {
  
  df <- df %>% select(-one_of("...33"))  # Remove the unnamed column
  
}


# Clean column names

df <- df %>% clean_names()


# Inspect the dataset

glimpse(df)  # Get a quick overview of the dataset structure

summary(df)  # Get summary statistics for each column


# Display the first few rows

head(df)


# Check for missing values

missing_values <- colSums(is.na(df))

print("Missing Values:")

print(missing_values)


# Descriptive statistics

descriptive_stats <- df %>%
  
  summarise(
    
    count = n(),
    
    mean_radius = mean(radius_mean, na.rm = TRUE),
    
    mean_area = mean(area_mean, na.rm = TRUE),
    
    mean_diagnosis = mean(ifelse(diagnosis == "M", 1, 0), na.rm = TRUE)
    
  )

print("Descriptive Statistics:")

print(descriptive_stats)


# Create visuals folder if it doesn't exist

if (!dir.exists("eda/visuals")) {
  
  dir.create("eda/visuals")
  
}


# Visualizations


# Histogram of radius_mean

hist_plot <- ggplot(df, aes(x = radius_mean)) +
  
  geom_histogram(bins = 30, fill = "blue", color = "white") +
  
  labs(title = "Distribution of Radius Mean", x = "Radius Mean", y = "Count") +
  
  theme_minimal()


# Save histogram plot

ggsave("eda/visuals/histogram_radius_mean.png", plot = hist_plot)


# Boxplot of area_mean by diagnosis

boxplot_area <- ggplot(df, aes(x = diagnosis, y = area_mean, fill = diagnosis)) +
  
  geom_boxplot() +
  
  labs(title = "Area Mean by Diagnosis", x = "Diagnosis", y = "Area Mean") +
  
  theme_minimal()


# Save boxplot

ggsave("eda/visuals/boxplot_area_mean.png", plot = boxplot_area)


# Group summary statistics by diagnosis

grouped_stats <- df %>%
  
  group_by(diagnosis) %>%
  
  summarise(
    
    count = n(),
    
    mean_radius = mean(radius_mean, na.rm = TRUE),
    
    mean_area = mean(area_mean, na.rm = TRUE)
    
  )

print("Grouped Summary Statistics by Diagnosis:")

print(grouped_stats)


# Correlation matrix for numeric variables

correlation_matrix <- cor(df %>% select(where(is.numeric)), use = "complete.obs")

print("Correlation Matrix:")

print(correlation_matrix)


# Additional visualizations


# Create a new dataframe with only numeric columns

numeric_df <- df %>% select(radius_mean, area_mean, smoothness_mean, diagnosis)


# Convert diagnosis to a factor for coloring

numeric_df$diagnosis <- as.factor(numeric_df$diagnosis)


# Create pairwise scatter plots using ggpairs

pairs_plot <- ggpairs(numeric_df, 
                      
                      aes(color = diagnosis, alpha = 0.5),
                      
                      title = "Pairwise Scatter Plots of Selected Features")


# Save pairwise scatter plot as PNG

ggsave("eda/visuals/pairwise_scatter_plots.png", plot = pairs_plot)


# Print the pairs plot

print(pairs_plot)