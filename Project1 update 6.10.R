##### Townsend Project --------------------
setwd("C:/Users/Scarlett/Downloads")
rm(list=ls(all=TRUE))
# import the CSV file
#data <- read.csv("1987_top100.csv", stringsAsFactors = FALSE)
#data <- read.csv("1987_top1000.csv", stringsAsFactors = FALSE)
data <- read.csv("1987.csv", stringsAsFactors = FALSE)

#Part 2: Summarize the data. 
#2.1 How many variables are included in the dataset? 

str(data)
#1311826 observations of 29 variables

#2.1 List the Categorical features.
attach(data)
sapply(data,class)
detach(data)


data.log<-data[,sapply(data,is.logical)]
attach(data.log)
names(data.log)
detach(data.log)
#These are all NA in the raw data

#recode as factors
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

#removes all cancelled and diverted flights
data=subset(data, Cancelled==0&Diverted==0)

#subset the data to drop extraneous columns
data <- data[,-c(1,11,14,20,21:29)]  
str(data)
#1288326  observations of 16 variables

#2.2 Compute means and standard deviations for the Numeric features for each month of 1987.
#for the whole set
format(sapply(data.int,mean),digits=2)
format(sapply(data.int,sd),digits=2)

#by month
aggregate(data.int, by=list(data.int$Month), mean, na.rm=TRUE)
aggregate(data.int, by=list(data.int$Month), sd, na.rm=TRUE)

#2.3 Make tables of counts and relative frequencies for the Categorical features for each month of 1987.
summary(data.char)

library('dplyr')

#  Add logical variable to identify months
Oct=ifelse(data$Month==10,1,0)
Nov=ifelse(data$Month==11,1,0)
Dec=ifelse(data$Month==12,1,0)

data = cbind(data,Oct,Nov,Dec)

#Summarize UniqueCarrier
carr.cnt=summarise(group_by(data, UniqueCarrier), Count_Oct=sum(Oct),  Count_Nov=sum(Nov),  Count_Dec=sum(Dec)) 
Prop_Oct=100*carr.cnt$Count_Oct/sum(carr.cnt$Count_Oct)
Prop_Nov=100*carr.cnt$Count_Nov/sum(carr.cnt$Count_Nov)
Prop_Dec=100*carr.cnt$Count_Dec/sum(carr.cnt$Count_Dec)
carr.cnt=cbind(carr.cnt,Prop_Oct,Prop_Nov,Prop_Dec)
carr.cnt

#Summarize Origin
origin.cnt=summarise(group_by(data, Origin), Count_Oct=sum(Oct),  Count_Nov=sum(Nov),  Count_Dec=sum(Dec)) 
Prop_Oct=100*origin.cnt$Count_Oct/sum(origin.cnt$Count_Oct)
Prop_Nov=100*origin.cnt$Count_Nov/sum(origin.cnt$Count_Nov)
Prop_Dec=100*origin.cnt$Count_Dec/sum(origin.cnt$Count_Dec)
origin.cnt=cbind(origin.cnt,Prop_Oct,Prop_Nov,Prop_Dec)
origin.cnt

#Summarize Dst
dest.cnt=summarise(group_by(data, Dest), Count_Oct=sum(Oct),  Count_Nov=sum(Nov),  Count_Dec=sum(Dec)) 
Prop_Oct=100*dest.cnt$Count_Oct/sum(dest.cnt$Count_Oct)
Prop_Nov=100*dest.cnt$Count_Nov/sum(dest.cnt$Count_Nov)
Prop_Dec=100*dest.cnt$Count_Dec/sum(dest.cnt$Count_Dec)
dest.cnt=cbind(dest.cnt,Prop_Oct,Prop_Nov,Prop_Dec)
dest.cnt

#Part 3: Create a variable ArrivedLate
#3.1 Using variables in the dataset create a new variable that indicated that the flight arrived late.

data$ArrivedLate <- as.factor(data$ArrDelay > 15) # allow 15 min grace period for on-time)
summary(data$ArrivedLate)

#3.2 (Stat. 6620 students only) Using a function in R, verify that the time delay calculations are correct.

data$ArrTimeMins = floor(data$ArrTime/100)*60+(data$ArrTime-floor(data$ArrTime/100)*100)
data$CRSArrTimeMins= floor(data$CRSArrTime/100)*60+(data$CRSArrTime-floor(data$CRSArrTime/100)*100)
data$Check <- ifelse(data$ArrDelay - data$ArrTimeMins + data$CRSArrTimeMins==0||data$ArrDelay - data$ArrTimeMins + data$CRSArrTimeMins==1440,1,0)

subset(data,!data$Check==1) # The calculations appear to be correct

#Part 4:  Classification:
#4.1Apply the kNN algorithm to the dataset to predict ArrivedLate. 

# create a random sample for training and test data
# use set.seed to use the same random number sequence as the tutorial
set.seed(12345)

#recode origin and destination to numeric
prop.table(table(data$Origin))
OriginList=sort(unique(data$Origin))
data$Origin<- as.character(1:length(OriginList))[ match(data$Origin, OriginList ) ]
data$Origin<- as.integer(data$Origin)
prop.table(table(data$Origin))


prop.table(table(data$Dest))
DestList=sort(unique(data$Dest))
data$Dest<- as.character(1:length(DestList))[ match(data$Dest, DestList ) ]
data$Dest<- as.integer(data$Dest)
prop.table(table(data$Dest))

prop.table(table(data$UniqueCarrier))
UniqueCarrierList=sort(unique(data$UniqueCarrier))
data$UniqueCarrier<- as.character(1:length(UniqueCarrierList))[ match(data$UniqueCarrier, UniqueCarrierList ) ]
data$UniqueCarrier<- as.integer(data$Dest)
prop.table(table(data$UniqueCarrier))



#check for missing values
str(data[!complete.cases(data),])

#Drop missing cases
data=data[complete.cases(data),]
str(data)

#Drop the columns used to check the calculations and reorder columns
str(data)
data <- data[,c(20,1:16)]
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
data_n <- as.data.frame(lapply(data_rand[2:16], normalize))
summary(data_n)

# split the data frames 
  #data_train <- data_n[1:260000,]
  #data_test  <- data_n[260001:1287333, ] 

#this one eliminates all but top 6 correlated variables
data_test <- data_n[1:260000,c(1,4,5,7,10,13)]
data_train  <- data_n[260001:1287333,c(1,4,5,7,10,13) ] 

#used this to verify it was just slow
#data_train <- data_n[1:260,c(1,4,5,7,10,13)]
#data_test  <- data_n[261:1287,c(1,4,5,7,10,13) ] 

#check for missing values
data_train[!complete.cases(data_train),]
data_test[!complete.cases(data_test),]

# create labels for training and test data
  #data_train_labels <- data_rand[1:260000,1]
  #data_test_labels  <- data_rand[260001:1287333,1] 

#this one eliminates all but top 6 correlated variables
data_test_labels <- data_rand[1:260000,1]
data_train_labels  <- data_rand[260001:1287333,1] 

#check for missing values
data_train_labels[!complete.cases(data_train_labels)]
data_test_labels[!complete.cases(data_test_labels)]

# check the proportion of class variable
prop.table(table((data_train_labels)))
prop.table(table((data_test_labels)))

library(class)
library(gmodels)

#run with different values of k
data_test_pred <- knn(data_train, data_test, data_train_labels, k=1)
CrossTable(x = data_test_labels, y = data_test_pred, prop.chisq=FALSE)

data_test_pred <- knn(train = data_train, test = data_test, cl = data_train_labels, k=5)
CrossTable(x = data_test_labels, y = data_test_pred, prop.chisq=FALSE)

data_test_pred <- knn(train = data_train, test = data_test, cl = data_train_labels, k=10)
CrossTable(x = data_test_labels, y = data_test_pred, prop.chisq=FALSE)

data_test_pred <- knn(train = data_train, test = data_test, cl = data_train_labels, k=15)
CrossTable(x = data_test_labels, y = data_test_pred, prop.chisq=FALSE)

data_test_pred <- knn(train = data_train, test = data_test, cl = data_train_labels, k=20)
CrossTable(x = data_test_labels, y = data_test_pred, prop.chisq=FALSE)


#Part 5: Prediction
#5.1 Examine the correlation between ArrDelay and the other quantitative variables in the dataset
cor(data[2:17])
require('corrplot')
corrplot(cor(data[2:17]))

#5.2 Apply the Regression Tree algorithm to the dataset to predict the ArrDelay.

# the distribution of ArrDelay
hist(data$ArrDelay,breaks=200,main="Figure 2 - Arrival Delay Frequency", xlab="Minutes",xlim=c(-50,200))  

# create labels for training and test data
rt_data_train <- data[1:260000,2:17 ]
rt_data_test  <- data[260001:1287333,2:17 ] 

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
rpart.plot(m.rpart, digits = 3,main="Figure 3 - Arrival Delay Decision Tree")

# a few adjustments to the diagram
rpart.plot(m.rpart, digits = 4, fallen.leaves = TRUE, type = 3, extra = 101,main="Figure 3 - Arrival Delay Decision Tree")

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

#Improving model performance ----
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
a=subset(data,ArrivedLate==TRUE)
b=subset(data,ArrivedLate==FALSE)

par(mfrow=c(1,2))
plot(density(a$DepDelay),xlim=c(-50,200),ylim=c(0,2.5),main="Figure 4 - ROC Curve")
lines(density(b$DepDelay),col="red")

plot(density(a$DepDelay),xlim=c(-20,40),ylim=c(0,.05),main="Figure 4 - ROC Curve Magnification")
lines(density(b$DepDelay),col="red")


