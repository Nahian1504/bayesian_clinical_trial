# Load necessary libraries

library(testthat)

library(readr)


# Set the working directory to the location of your data

setwd("E:/bayesian_clinical_trial")  # Ensure this is set to the correct path


# Load the cleaned data

df_clean <- read_csv("data/real_clinical_trial.csv")


# Test to ensure there are no NA values in the diagnosis column

test_that("Data quality test: No NA values in diagnosis", {
  
  expect_false(any(is.na(df_clean$diagnosis)), 
               
               info = "There are NA values in the diagnosis column.")
  
})


# Test to ensure the diagnosis column is of the expected type (character or factor)

test_that("Data quality test: Diagnosis column type", {
  
  expect_true(is.character(df_clean$diagnosis) || is.factor(df_clean$diagnosis), 
              
              info = "Diagnosis column should be of type character or factor.")
  
})


# Test to ensure the data frame is not empty

test_that("Data quality test: Data frame is not empty", {
  
  expect_gt(nrow(df_clean), 0, 
            
            "The data frame is empty.")
  
})


# Test to ensure the expected columns are present

expected_columns <- c("id", "diagnosis", "radius_mean", "texture_mean", "perimeter_mean", 
                      
                      "area_mean", "smoothness_mean", "compactness_mean", "concavity_mean", 
                      
                      "concave points_mean", "symmetry_mean", "fractal_dimension_mean", 
                      
                      "radius_se", "texture_se", "perimeter_se", "area_se", 
                      
                      "smoothness_se", "compactness_se", "concavity_se", 
                      
                      "concave points_se", "symmetry_se", "fractal_dimension_se", 
                      
                      "radius_worst", "texture_worst", "perimeter_worst", 
                      
                      "area_worst", "smoothness_worst", "compactness_worst", 
                      
                      "concavity_worst", "concave points_worst", "symmetry_worst", 
                      
                      "fractal_dimension_worst")


test_that("Data quality test: Expected columns are present", {
  
  expect_true(all(expected_columns %in% colnames(df_clean)), 
              
              "Not all expected columns are present in the data frame.")
  
})


# Test to ensure numeric columns are within reasonable ranges

numeric_columns <- c("radius_mean", "texture_mean", "perimeter_mean", "area_mean", 
                     
                     "smoothness_mean", "compactness_mean", "concavity_mean", 
                     
                     "concave points_mean", "symmetry_mean", "fractal_dimension_mean", 
                     
                     "radius_se", "texture_se", "perimeter_se", "area_se", 
                     
                     "smoothness_se", "compactness_se", "concavity_se", 
                     
                     "concave points_se", "symmetry_se", "fractal_dimension_se", 
                     
                     "radius_worst", "texture_worst", "perimeter_worst", 
                     
                     "area_worst", "smoothness_worst", "compactness_worst", 
                     
                     "concavity_worst", "concave points_worst", "symmetry_worst", 
                     
                     "fractal_dimension_worst")


for (col in numeric_columns) {
  
  test_that(paste("Data quality test: ", col, " is numeric and within range", sep = ""), {
    
    if (col %in% colnames(df_clean)) {
      
      expect_true(is.numeric(df_clean[[col]]), 
                  
                  info = paste(col, "should be numeric."))
      
      expect_true(all(df_clean[[col]] >= 0), 
                  
                  info = paste(col, "values should be non-negative."))
      
    } else {
      
      warning(paste(col, "column is not present in the data frame."))
      
    }
    
  })
  
}