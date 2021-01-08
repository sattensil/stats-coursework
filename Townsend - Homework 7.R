#Scarlett Townsnend

#Read Chapter 9 Clustering
#Perform the Cluster analysis on the SNS data.
#Read Chapter 8 Market Basket Analysis Using Association Rule
#Perform the analysis presented in the Chapter on the grocery data.

##### Chapter 9: Clustering with k-means -------------------

## Example: Finding Teen Market Segments ----
## Step 2: Exploring and preparing the data ----
teens <- read.csv("C:/Users/Scarlett/Downloads/snsdata.csv")
str(teens)

# look at missing data for female variable
table(teens$gender)
table(teens$gender, useNA = "ifany")

# look at missing data for age variable
summary(teens$age)

# eliminate age outliers
teens$age <- ifelse(teens$age >= 13 & teens$age < 20,
                    teens$age, NA)

summary(teens$age)

# reassign missing gender values to "unknown"
teens$female <- ifelse(teens$gender == "F" &
                         !is.na(teens$gender), 1, 0)
teens$no_gender <- ifelse(is.na(teens$gender), 1, 0)

# check our recoding work
table(teens$gender, useNA = "ifany")
table(teens$female, useNA = "ifany")
table(teens$no_gender, useNA = "ifany")

# finding the mean age by cohort
mean(teens$age) # doesn't work
mean(teens$age, na.rm = TRUE) 

# age by cohort
aggregate(data = teens, age ~ gradyear, mean, na.rm = TRUE)

# calculating the expected age for each person
ave_age <- ave(teens$age, teens$gradyear,
               FUN = function(x) mean(x, na.rm = TRUE))


teens$age <- ifelse(is.na(teens$age), ave_age, teens$age)

# check the summary results to ensure missing values are eliminated
summary(teens$age)

## Step 3: Training a model on the data ----
interests <- teens[5:40]
interests_z <- as.data.frame(lapply(interests, scale))

teen_clusters <- kmeans(interests_z, 5)

## Step 4: Evaluating model performance ----
# look at the size of the clusters
teen_clusters$size

# look at the cluster centers
teen_clusters$centers

## Step 5: Improving model performance ----
# apply the cluster IDs to the original data frame
teens$cluster <- teen_clusters$cluster

# look at the first five records
teens[1:5, c("cluster", "gender", "age", "friends")]

# mean age by cluster
aggregate(data = teens, age ~ cluster, mean)

# proportion of females by cluster
aggregate(data = teens, female ~ cluster, mean)

# mean number of friends by cluster
aggregate(data = teens, friends ~ cluster, mean)

##### Chapter 8: Association Rules -------------------

## Example: Identifying Frequently-Purchased Groceries ----
## Step 2: Exploring and preparing the data ----

# load the grocery data into a sparse matrix
library(arules)
groceries <- read.transactions("C:/Users/Scarlett/Downloads/groceries.csv", sep = ",")
summary(groceries)

# look at the first five transactions
inspect(groceries[1:5])

# examine the frequency of items
itemFrequency(groceries[, 1:3])

# plot the frequency of items
itemFrequencyPlot(groceries, support = 0.1)
itemFrequencyPlot(groceries, topN = 20)

# a visualization of the sparse matrix for the first five transactions
image(groceries[1:5])

# visualization of a random sample of 100 transactions
image(sample(groceries, 100))

## Step 3: Training a model on the data ----
library(arules)

# default settings result in zero rules learned
apriori(groceries)

# set better support and confidence levels to learn more rules
groceryrules <- apriori(groceries, parameter = list(support =
                                                      0.006, confidence = 0.25, minlen = 2))
groceryrules

## Step 4: Evaluating model performance ----
# summary of grocery association rules
summary(groceryrules)

# look at the first three rules
inspect(groceryrules[1:3])

## Step 5: Improving model performance ----

# sorting grocery rules by lift
inspect(sort(groceryrules, by = "lift")[1:5])

# finding subsets of rules containing any berry items
berryrules <- subset(groceryrules, items %in% "berries")
inspect(berryrules)

# writing the rules to a CSV file
write(groceryrules, file = "groceryrules.csv",
      sep = ",", quote = TRUE, row.names = FALSE)

# converting the rule set to a data frame
groceryrules_df <- as(groceryrules, "data.frame")
str(groceryrules_df)