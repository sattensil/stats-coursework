##### Chapter 3: Classification using Nearest Neighbors --------------------

## Example: Classifying Cancer Samples ----
## Step 2: Exploring and preparing the data ---- 
setwd ("C:/Users/Scarlett/Downloads")

# import the CSV file
iris <- read.csv("iris.csv", stringsAsFactors = FALSE)

# examine the structure of the iris data frame
str(iris)

# table of classes
table(iris$class)

# recode diagnosis as a factor
iris$class <- factor(iris$class, levels = c("Iris-setosa", "Iris-versicolor", "Iris-virginica"),
                         labels = c("setosa", "versicolor", "virginica"))

# table or proportions with more informative labels
round(prop.table(table(iris$class)) * 100, digits = 1)

# summarize three numeric features
summary(iris[c("sep_len", "sep_wid","pet_len", "pet_wid")])

# create normalization function
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))}

# test normalization function - result should be identical
normalize(c(1, 2, 3, 4, 5))
normalize(c(10, 20, 30, 40, 50))

# normalize the iris data
iris_n <- as.data.frame(lapply(iris[1:4], normalize))

# confirm that normalization worked
summary(iris_n$sep_len)

# create training and test data
iris_train <- iris_n[-c(2:11,52:61,102:111), ]
iris_test <- iris_n[c(2:11,52:61,102:111), ]

# create labels for training and test data

iris_train_labels <- iris[-c(2:11,52:61,102:111), 5]
iris_test_labels <- iris[c(2:11,52:61,102:111), 5]

## Step 3: Training a model on the data ----

# load the "class" library
library(class)

iris_test_pred <- knn(train = iris_train, test = iris_test,
                      cl = iris_train_labels, k=5)

## Step 4: Evaluating model performance ----

# load the "gmodels" library
library(gmodels)

# Create the cross tabulation of predicted vs. actual
CrossTable(x = iris_test_labels, y = iris_test_pred,
           prop.chisq=FALSE)

## Step 5: Improving model performance ----

# use the scale() function to z-score standardize a data frame
iris_z <- as.data.frame(scale(iris[-5]))

# confirm that the transformation was applied correctly
summary(iris_z$sep_len)

# create training and test datasets
iris_train <- iris_z[-c(2:11,52:61,102:111), ]
iris_test <- iris_z[c(2:11,52:61,102:111), ]

# re-classify test cases
iris_test_pred <- knn(train = iris_train, test = iris_test,
                      cl = iris_train_labels, k=5)

# Create the cross tabulation of predicted vs. actual
CrossTable(x = iris_test_labels, y = iris_test_pred,
           prop.chisq=FALSE)

# try several different values of k with the standardized data

iris_test_pred <- knn(train = iris_train, test = iris_test, cl = iris_train_labels, k=1)
CrossTable(x = iris_test_labels, y = iris_test_pred, prop.chisq=FALSE)

iris_test_pred <- knn(train = iris_train, test = iris_test, cl = iris_train_labels, k=5)
CrossTable(x = iris_test_labels, y = iris_test_pred, prop.chisq=FALSE)

iris_test_pred <- knn(train = iris_train, test = iris_test, cl = iris_train_labels, k=10)
CrossTable(x = iris_test_labels, y = iris_test_pred, prop.chisq=FALSE)

iris_test_pred <- knn(train = iris_train, test = iris_test, cl = iris_train_labels, k=15)
CrossTable(x = iris_test_labels, y = iris_test_pred, prop.chisq=FALSE)

iris_test_pred <- knn(train = iris_train, test = iris_test, cl = iris_train_labels, k=30)
CrossTable(x = iris_test_labels, y = iris_test_pred, prop.chisq=FALSE)

iris_test_pred <- knn(train = iris_train, test = iris_test, cl = iris_train_labels, k=50)
CrossTable(x = iris_test_labels, y = iris_test_pred, prop.chisq=FALSE)

# try several different values of k with the non-standardized data

iris_train <- iris_n[-c(2:11,52:61,102:111), ]
iris_test <- iris_n[c(2:11,52:61,102:111), ]

iris_test_pred <- knn(train = iris_train, test = iris_test, cl = iris_train_labels, k=1)
CrossTable(x = iris_test_labels, y = iris_test_pred, prop.chisq=FALSE)

iris_test_pred <- knn(train = iris_train, test = iris_test, cl = iris_train_labels, k=5)
CrossTable(x = iris_test_labels, y = iris_test_pred, prop.chisq=FALSE)

iris_test_pred <- knn(train = iris_train, test = iris_test, cl = iris_train_labels, k=10)
CrossTable(x = iris_test_labels, y = iris_test_pred, prop.chisq=FALSE)

iris_test_pred <- knn(train = iris_train, test = iris_test, cl = iris_train_labels, k=15)
CrossTable(x = iris_test_labels, y = iris_test_pred, prop.chisq=FALSE)

iris_test_pred <- knn(train = iris_train, test = iris_test, cl = iris_train_labels, k=30)
CrossTable(x = iris_test_labels, y = iris_test_pred, prop.chisq=FALSE)

iris_test_pred <- knn(train = iris_train, test = iris_test, cl = iris_train_labels, k=50)
CrossTable(x = iris_test_labels, y = iris_test_pred, prop.chisq=FALSE)