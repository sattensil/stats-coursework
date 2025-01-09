##### Townsend Project --------------------
setwd("C:/Users/Scarlett/Downloads")
# import the CSV file
data <- read.csv("1987_top100.csv", stringsAsFactors = FALSE)

#Part 2: Summarize the data. 
#2.1 How many variables are included in the dataset? 

str(data)
#99/999 observations of 29 variables

#2.1 List the Categorical features.
attach(data)
sapply(data,class)
data.log<-data[,sapply(data,is.logical)]
attach(data.log)
names(data.log)
#These are all NA in the raw data

data$UniqueCarrier <- as.factor(data$UniqueCarrier )
data$Origin <- as.factor(data$Origin)
data$Dest <- as.factor(data$Dest)

data.char<-data[,sapply(data,is.factor)]
attach(data.char)
names(data.char)

#2.1 List the Numeric features.
data.int<-data[,sapply(data,is.integer)]
attach(data.int)
names(data.int)
#Cancelled and Diverted appear to be logical

#Creating a cleaner data set

#removes all cancelled flights
data=subset(data, Cancelled==0)
str(data)
#96/ observations of 29 variables

#subset the data to drop extraneous columns
data <- data[,-c(1,9,11,14,20,21:29)]  
str(data)
#96/ observations of 15 variables

#2.2 Compute means and standard deviations for the Numeric features for each month of 1987.
#for the whole set
format(sapply(data.int,mean),digits=2)
format(sapply(data.int,sd),digits=2)

#by month
aggregate(data.int, by=list(data.int$Month), mean, na.rm=TRUE)
aggregate(data.int, by=list(data.int$Month), sd, na.rm=TRUE)

#2.3 Make tables of counts and relative frequencies for the Categorical features for each month of 1987.
summary(data.char)
prop.table(table(data.char$UniqueCarrier))
prop.table(table(data.char$Origin ))
prop.table(table(data.char$Dest))

#Part 3: Create a variable ArrivedLate
#3.1 Using variables in the dataset create a new variable that indicated that the flight arrived late.

data$ArrivedLate <- as.factor(data$ArrDelay > 15) # allow 15 min grace period for on-time)
summary(data$ArrivedLate)

#3.2 (Stat. 6620 students only) Using a function in R, verify that the time delay calculations are correct.

data$ArrTimeMins = floor(data$ArrTime/100)*60+(data$ArrTime-floor(data$ArrTime/100)*100)
data$CRSArrTimeMins= floor(data$CRSArrTime/100)*60+(data$CRSArrTime-floor(data$CRSArrTime/100)*100)
data$Check <- data$ArrDelay - data$ArrTimeMins + data$CRSArrTimeMins

data$Check # The calculations appear to be correct

#Part 4:  Classification:
#4.1Apply the kNN algorithm to the dataset to predict ArrivedLate. 

# create a random sample for training and test data
# use set.seed to use the same random number sequence as the tutorial
set.seed(12345)

#recode origin and destination to numeric
prop.table(table(data$Origin))
data$Origin<- as.character(1:11)[ match(data$Origin, c('BUR','LAS','LAX','OAK','PDX','RNO','SAN','SFO','SJC','SNA','SMF') ) ]
data$Origin<- as.integer(data$Origin)
prop.table(table(data$Origin))


prop.table(table(data$Dest))
data$Dest<- as.character(1:11)[ match(data$Dest, c('BUR','LAS','LAX','OAK','PDX','RNO','SAN','SFO','SJC','SNA','SMF') ) ]
data$Dest<- as.integer(data$Dest)
prop.table(table(data$Dest))

#Drop the columns used to check the calculations and reorder columns
str(data)
data <- data[,c(16,2:15)]  ##DROPPED MONTH HERE BECAUSE WAS ONLY ONE
str(data)

#randomize the data
data_rand <- data[order(runif(nrow(data))), ]
str(data_rand)

# compare the data and data_rand data frames
prop.table(table(data$ArrivedLate))
prop.table(table(data_rand$ArrivedLate))

#normalize the data
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}
data_n <- as.data.frame(lapply(data_rand[2:15], normalize))
str(data_n)

# split the data frames 
data_train <- data_n[1:20, ]
data_test  <- data_n[21:96, ] 
#data_test  <- data_n[21:999, ] ##UPDATE TO LARGER NUMBER ONCE GET FULL DATA

#check for missing values
data_train[!complete.cases(data_train),]
data_test[!complete.cases(data_test),]

# check the proportion of class variable
prop.table(table(data_train$ArrivedLate))
prop.table(table(data_test$ArrivedLate))

# create labels for training and test data
data_train_labels <- data_rand[1:20,1]
data_test_labels  <- data_rand[21:96,1] 
#data_test_labels  <- data_rand[21:999, 1] ##UPDATE TO LARGER NUMBER ONCE GET FULL DATA

#check for missing values
data_train_labels[!complete.cases(data_train_labels)]
data_test_labels[!complete.cases(data_test_labels)]

library(class)
library(gmodels)

#run with different values of k
data_test_pred <- knn(data_train, data_test, data_train_labels, k=1,prob=TRUE)
CrossTable(x = data_test_labels, y = data_test_pred, prop.chisq=FALSE)

data_test_pred <- knn(train = data_train, test = data_test, cl = data_train_labels, k=5)
CrossTable(x = data_test_labels, y = data_test_pred, prop.chisq=FALSE)

data_test_pred <- knn(train = data_train, test = data_test, cl = data_train_labels, k=10)
CrossTable(x = data_test_labels, y = data_test_pred, prop.chisq=FALSE)

data_test_pred <- knn(train = data_train, test = data_test, cl = data_train_labels, k=20)
CrossTable(x = data_test_labels, y = data_test_pred, prop.chisq=FALSE)

data_test_pred <- knn(train = data_train, test = data_test, cl = data_train_labels, k=25)
CrossTable(x = data_test_labels, y = data_test_pred, prop.chisq=FALSE)

data_test_pred <- knn(train = data_train, test = data_test, cl = data_train_labels, k=30)
CrossTable(x = data_test_labels, y = data_test_pred, prop.chisq=FALSE)

#Part 5: Prediction
#5.1 Examine the correlation between ArrDelay and the other quantitative variables in the dataset
cor(data[2:15])
require('corrplot')
corrplot(cor(data[2:15]))

#5.2 Apply the Regression Tree algorithm to the dataset to predict the ArrDelay.

## Understanding regression trees and model trees ----
## Example: Calculating SDR ----
# set up the data
tee <- c(1, 1, 1, 2, 2, 3, 4, 5, 5, 6, 6, 7, 7, 7, 7)
at1 <- c(1, 1, 1, 2, 2, 3, 4, 5, 5)
at2 <- c(6, 6, 7, 7, 7, 7)
bt1 <- c(1, 1, 1, 2, 2, 3, 4)
bt2 <- c(5, 5, 6, 6, 7, 7, 7, 7)

# compute the SDR
sdr_a <- sd(tee) - (length(at1) / length(tee) * sd(at1) + length(at2) / length(tee) * sd(at2))
sdr_b <- sd(tee) - (length(bt1) / length(tee) * sd(bt1) + length(bt2) / length(tee) * sd(bt2))

# compare the SDR for each split
sdr_a
sdr_b

#Exploring and preparing the data ----

# the distribution of ArrDelay
hist(data$ArrDelay, breaks=7)  

# summary statistics of the data
summary(data)

rt_data_train <- data[1:20,2:15 ]
rt_data_test  <- data[21:96,2:15 ] 
#rt_data_test  <- data_n[21:999, ] ##UPDATE TO LARGER NUMBER ONCE GET FULL DATA

## Step 3: Training a model on the data ----
# regression tree using rpart
library(rpart)
m.rpart <- rpart(ArrDelay ~ ., data = rt_data_train)

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
p.rpart <- predict(m.rpart, rt_data_test)

# compare the distribution of predicted values vs. actual values
summary(p.rpart)
summary(rt_data_test$ArrDelay)

# compare the correlation
cor(p.rpart, rt_data_test$ArrDelay)

# function to calculate the mean absolute error
MAE <- function(actual, predicted) {
  mean(abs(actual - predicted))  
}

# mean absolute error between predicted and actual values
MAE(p.rpart, rt_data_test$ArrDelay)

# mean absolute error between actual values and mean value
mean(rt_data_train$ArrDelay) 
MAE(18.75, rt_data_test$ArrDelay)               # **** correction  ****

## Step 5: Improving model performance ----
# train a M5' Model Tree
library(RWeka)
m.m5p <- M5P(ArrDelay ~ ., data = rt_data_test$ArrDelay)

# display the tree
m.m5p

# get a summary of the model's performance
summary(m.m5p)

# generate predictions for the model
p.m5p <- predict(m.m5p,rt_data_test)

# summary statistics about the predictions
summary(p.m5p)

# correlation between the predicted and true values
cor(p.m5p, rt_data_test$ArrDelay)

# mean absolute error of predicted and true values
# (uses a custom function defined above)
MAE(rt_data_test$ArrDelay, p.m5p)



#5.3 (Stat. 6620 students only)  Use the ROC curve to further examine the effectiveness of the model for prediction.


