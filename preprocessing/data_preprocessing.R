# Load necessary libraries

library(tidyverse)  # For data manipulation

library(janitor)    # For cleaning column names


# Load the dataset

df <- read_csv("data/real_clinical_trial.csv")


# Clean column names

df <- df %>% clean_names()


# Handle missing values

df <- df %>%
  
  mutate(across(where(is.numeric), ~ ifelse(is.na(.), mean(., na.rm = TRUE), .)))  # Impute numeric columns with mean


# Encode categorical variables

df <- df %>%
  
  mutate(diagnosis = as.factor(diagnosis))  # Convert diagnosis to factor


# Split the dataset into training and testing sets

set.seed(123)  # For reproducibility

train_index <- sample(1:nrow(df), 0.8 * nrow(df))

train_data <- df[train_index, ]

test_data <- df[-train_index, ]


# Save the preprocessed data

write_csv(train_data, "data/train_data.csv")

write_csv(test_data, "data/test_data.csv")