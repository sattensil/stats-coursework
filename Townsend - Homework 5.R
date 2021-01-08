
#Scarlett Townsend -- Homework #5

setwd("C:/Users/Scarlett/Downloads")

#Perform the Rule based analysis of the mushroom.
#### Part 2: Rule Learners -------------------

## Example: Identifying Poisonous Mushrooms ----
## Step 2: Exploring and preparing the data ---- 
mushrooms <- read.csv("mushrooms.csv", stringsAsFactors = TRUE)

# examine the structure of the data frame
str(mushrooms)

# drop the veil_type feature
mushrooms$veil_type <- NULL

# examine the class distribution
table(mushrooms$type)

# Rule Learner Using C5.0 Decision Trees (not in text)
library(C50)
mushroom_c5rules <- C5.0(type ~ odor + gill_size, data = mushrooms, rules = TRUE)
summary(mushroom_c5rules)


#Perform the regression analysis of the challenger data.
## Understanding regression ----
## Example: Space Shuttle Launch Data ----
launch <- read.csv("challenger.csv")

# estimate beta manually
b <- cov(launch$temperature, launch$distress_ct) / var(launch$temperature)
b

# estimate alpha manually
a <- mean(launch$distress_ct) - b * mean(launch$temperature)
a

# calculate the correlation of launch data
r <- cov(launch$temperature, launch$distress_ct) /
  (sd(launch$temperature) * sd(launch$distress_ct))
r
cor(launch$temperature, launch$distress_ct)

# computing the slope using correlation
r * (sd(launch$distress_ct) / sd(launch$temperature))

# confirming the regression line using the lm function (not in text)
model <- lm(distress_ct ~ temperature, data = launch)
model
summary(model)

# creating a simple multiple regression function
reg <- function(y, x) {
  x <- as.matrix(x)
  x <- cbind(Intercept = 1, x)
  solve(t(x) %*% x) %*% t(x) %*% y
}

# examine the launch data
str(launch)

# test regression model with simple linear regression
reg(y = launch$distress_ct, x = launch[3])

# use regression model with multiple regression
reg(y = launch$distress_ct, x = launch[3:5])

# confirming the multiple regression result using the lm function (not in text)
model <- lm(distress_ct ~ temperature + pressure + launch_id, data = launch)
model




#Perform the regression tree analysis of the whitewine data.
## Example: Estimating Wine Quality ----
## Step 2: Exploring and preparing the data ----
wine <- read.csv("whitewines.csv")

# examine the wine data
str(wine)

# the distribution of quality ratings
hist(wine$quality, breaks=7)             # *** correction ***

# summary statistics of the wine data
summary(wine)

wine_train <- wine[1:3750, ]
wine_test <- wine[3751:4898, ]

## Step 3: Training a model on the data ----
# regression tree using rpart
library(rpart)
m.rpart <- rpart(quality ~ ., data = wine_train)

# get basic information about the tree
m.rpart

# get more detailed information about the tree
summary(m.rpart)

# use the rpart.plot package to create a visualization
library(rpart.plot)

# a basic decision tree diagram
rpart.plot(m.rpart, digits = 3)

# a few adjustments to the diagram
rpart.plot(m.rpart, digits = 4, fallen.leaves = TRUE, type = 3, extra = 101)

## Step 4: Evaluate model performance ----

# generate predictions for the testing dataset
p.rpart <- predict(m.rpart, wine_test)

# compare the distribution of predicted values vs. actual values
summary(p.rpart)
summary(wine_test$quality)

# compare the correlation
cor(p.rpart, wine_test$quality)

# function to calculate the mean absolute error
MAE <- function(actual, predicted) {
  mean(abs(actual - predicted))  
}

# mean absolute error between predicted and actual values
MAE(p.rpart, wine_test$quality)

# mean absolute error between actual values and mean value
mean(wine_train$quality) # result = 5.87
MAE(5.87, wine_test$quality)               # **** correction  ****

## Step 5: Improving model performance ----
# train a M5' Model Tree
library(RWeka)
m.m5p <- M5P(quality ~ ., data = wine_train)

# display the tree
m.m5p

# get a summary of the model's performance
summary(m.m5p)

# generate predictions for the model
p.m5p <- predict(m.m5p, wine_test)

# summary statistics about the predictions
summary(p.m5p)

# correlation between the predicted and true values
cor(p.m5p, wine_test$quality)

# mean absolute error of predicted and true values
# (uses a custom function defined above)
MAE(wine_test$quality, p.m5p)