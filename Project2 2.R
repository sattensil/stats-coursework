

# import the CSV file
setwd("C:/Users/Scarlett/Downloads")
rm(list=ls(all=TRUE))
data <- read.csv("countiesdata.csv", stringsAsFactors = FALSE)

# examine the structure of the wbcd data frame
str(data)

#recode character variables as factors
data$county <- as.factor(data$county )
data$state<- as.factor(data$state )

summary(data)
#drop extra columns
data=data[,c(19,1:2,5:18)]
#Drop missing cases
data=data[complete.cases(data),]
str(data)

#recode county and state to numeric
head(prop.table(table(data$county)))
countyList=sort(unique(data$county))
data$county<- as.character(1:length(countyList))[ match(data$county, countyList ) ]
data$county<- as.integer(data$county)
head(prop.table(table(data$county)))

head(prop.table(table(data$state)))
stateList=sort(unique(data$state))
data$state<- as.character(1:length(stateList))[ match(data$state, stateList ) ]
data$state<- as.integer(data$state)
head(prop.table(table(data$state)))


# create normalization function
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))}

# apply normalization to entire data frame
data_norm <- as.data.frame(lapply(data, normalize))

# confirm that the range is now between zero and one
summary(data_norm)

#randomize the data
data_rand <- data_norm[order(runif(nrow(data))), ]
str(data_rand)

# create training and test data
data_train <- data_rand[1:650, ]
data_test <- data_rand[651:3114, ]

## Step 3: Training a model on the data ----
# train the neuralnet model
library(neuralnet)

# simple ANN with only a single hidden neuron
data_model <- neuralnet( formula= turnout ~ county + state + pop.density + pop + pop.change 
                                          + age6574 + age75 + crime + college + income 
                                          + farm + democrat + republican + Perot + white + black,
                                          data=data_train)

# visualize the network topology
plot(data_model)

# obtain model results
model_results <- compute(data_model, data_test[2:17])
# obtain predicted strength values
predicted_turnout <- model_results$net.result
# examine the correlation between predicted and actual values
cor(predicted_turnout, data_test$turnout)


# Determine the best number of hidden levels

Corr=rep(0,20)
for(k in 20:20)
{
  data_model <- neuralnet( formula= turnout ~ county + state + pop.density + pop + pop.change 
                            + age6574 + age75 + crime + college + income 
                            + farm + democrat + republican + Perot + white + black,
                            data=data_train, hidden = k)
  
  model_results <- compute(data_model, data_test[2:17])

  predicted_turnout <- model_results$net.result
  
  Corr[k]=cor(predicted_turnout, data_test$turnout)
}

#plot corrlations
plot(Corr,type="l",main="Figure 2 - Correlation Between Actual and Predicted Turnout", ylab="Correlation", xlab="Hidden Nodes")


#get topology
data_model <- neuralnet( formula= turnout ~ county + state + pop.density + pop + pop.change 
                         + age6574 + age75 + crime + college + income 
                         + farm + democrat + republican + Perot + white + black,
                         data=data_train, hidden = 2)

# visualize the network topology
plot(data_model)

cor(data)

Corr2=rep(0,10)
for(k in 0:10)
{
  data_model <- neuralnet( formula= turnout ~  
                           age6574 + age75 + college + income 
                           + farm +  Perot + white,
                           data=data_train, hidden = k)
  
  model_results <- compute(data_model, data_test[2:17])
  
  predicted_turnout <- model_results$net.result
  
  Corr2[k]=cor(predicted_turnout, data_test$turnout)
}

#plot corrlations
plot(Corr2,type="l",main="Figure 2 - Correlation Between Actual and Predicted Turnout", ylab="Correlation", xlab="Hidden Nodes")


#get topology
data_model <- neuralnet( formula= turnout ~ 
                         age6574 + age75 + college + income 
                         + farm +  Perot + white ,
                         data=data_train, hidden = 2)

# visualize the network topology
plot(data_model)











