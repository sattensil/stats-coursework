
## Example: Classifying Wholesale customers Samples ----
## Step 2: Exploring and preparing the data ---- 

# import the CSV file
WC_data <- read.csv("Wholesale customers data.csv", stringsAsFactors = FALSE)

# examine the structure of the wbcd data frame
str(WC_data)

# table of channel
table(WC_data$channel)

# recode channel as a factor
WC_data$channel <- factor(WC_data$channel, levels = c("1", "2"),
                         labels = c("Horeca", "Retail"))

# table or proportions with more informative labels
round(prop.table(table(WC_data$channel)) * 100, digits = 1)

# summarize three numeric features
summary(WC_data[c("Detergents_Paper", "Delicassen")])

# create normalization function
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))}

# test normalization function - result should be identical
normalize(c(1, 2, 3, 4, 5))
normalize(c(10, 20, 30, 40, 50))

# normalize the WC_data data
WC_data_n <- as.data.frame(lapply(WC_data[2:6], normalize))

# confirm that normalization worked
summary(WC_data_n$Delicassen)

