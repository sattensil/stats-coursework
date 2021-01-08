### ACTIVITY 1
### synthetic data

# Consider book price (y) by number of pages (x)

z = c("hardcover","hardcover",
      "hardcover","hardcover",
      "paperback", "paperback","paperback", 
      "paperback")

x1 = c( 150, 225, 342, 185)
y1 = c( 27.43, 48.76, 50.25, 32.01 )

x2 = c( 475, 834, 1020, 790)
y2 = c( 10.00, 15.73, 20.00, 17.89 )

x = c(x1, x2)
y = c(y1, y2)

plot(x,y)

# correlation

cor(y, x)
cor(y1, x1)
cor(y2, x2)
# linear regression
lm(y ~ x)
# linear regression
lm(y2 ~ x2)
plot(x,y, type="n")
text(x,y,z, cex=0.8)
# fitted linear regression

plot(x,y)

model0 <- lm(y ~ x)
abline(model0)

# fitted linear regression

plot(x,y)

text(200,40,"hardcover")
model1 <- lm(y1 ~ x1)
abline(model1)

text(600,15,"paperback")
model2 <- lm(y2 ~ x2)
abline(model2)
library(ggplot2)

# put the data into a data.frame
#   cond = type of book
#   xvar = x
#   yvar = y

dat <- data.frame(cond = z, xvar = x, yvar = y)
ggplot(dat, aes(x=xvar, y=yvar)) + geom_point(shape=1)      # Use hollow circles
ggplot(dat, aes(x=xvar, y=yvar)) +
  geom_point(shape=1) +    # Use hollow circles
  geom_smooth(method=lm)   # Add linear regression line 
ggplot(dat, aes(x=xvar, y=yvar)) +
  geom_point(shape=1) +    # Use hollow circles
  geom_smooth(method=lm,   # Add linear regression line
              se=FALSE)    # Don't add shaded confidence region
ggplot(dat, aes(x=xvar, y=yvar, color=cond)) + geom_point(shape=1)
# Same, but with different colors and add regression lines
ggplot(dat, aes(x=xvar, y=yvar, color=cond)) +
  geom_point(shape=1) +
  scale_colour_hue(l=50) + # Use a slightly darker palette than normal
  geom_smooth(method=lm,   # Add linear regression lines
              se=FALSE)    # Don't add shaded confidence region
# Set shape by cond
ggplot(dat, aes(x=xvar, y=yvar, shape=cond)) + geom_point()
# Same, but with different shapes
ggplot(dat, aes(x=xvar, y=yvar, shape=cond)) + geom_point() +
  scale_shape_manual(values=c(1,2))  # Use a hollow circle and triangle

### ACTIVITY 2

# Load the data
crime <- read.csv('crimeRatesByState2005.csv', sep=",", header=TRUE)

# Remove US total and DC
crime2 <- crime[crime$state != "District of Columbia",]
crime2 <- crime2[crime2$state != "United States",]


# Scatterplot for murder and burglary
plot(crime$murder, crime$burglary)
plot(crime2$murder, crime2$burglary)
plot(crime2$murder, crime2$burglary, xlim=c(0,10), ylim=c(0, 1200))

# Scatterplot with loess smoother
scatter.smooth(crime2$murder, crime2$burglary, xlim=c(0,10), ylim=c(0, 1200))



# Scatterplot matrix
plot(crime2[,2:9])

# Scatterplot matrix with loess
pairs(crime2[,2:9], panel=panel.smooth)

### ACTIVITY 3

library(corrgram)
corrgram(crime2, order=TRUE, 
         lower.panel=panel.shade,
         upper.panel=panel.pie, 
         text.panel=panel.txt,
         main="Crime Data")

corrgram(crime2, order=TRUE, 
         lower.panel=panel.ellipse,
         upper.panel=panel.pts, 
         text.panel=panel.txt,
         diag.panel=panel.minmax, 
         main="Crime Data")


### ACTIVITY 5

birth <- read.csv("birth-rate.csv")

# Histogram
hist(birth$X2008)
hist(birth$X2008, breaks=5)
hist(birth$X2008, breaks=20)

### ACTIVITY 6
# Examples from ggplot2 by Hadley Wickham

library(ggplot2)

summary(diamonds)

# qplot is quick plot in ggplot2

# Scatterplots

qplot(carat, price, data=diamonds)

qplot(log(carat), log(price), data=diamonds)

# aesthetic attributes

qplot(carat, price, data=diamonds, colour=I("red"))

qplot(carat, price, data=diamonds, size = I(1))

qplot(carat, price, data=diamonds, alpha=I(1/10))
qplot(carat, price, data=diamonds, alpha=I(1/100))
qplot(carat, price, data=diamonds, alpha=I(1/200))

# geometric objects - smooth is loess

qplot(carat, price, data=diamonds, geom=c("point","smooth"))

# Histogram

qplot(carat, data=diamonds, geom="histogram")

qplot(carat, data=diamonds, geom="histogram", binwidth=1, xlim=c(0,3))
qplot(carat, data=diamonds, geom="histogram", binwidth=0.1, xlim=c(0,3))
qplot(carat, data=diamonds, geom="histogram", binwidth=0.01, xlim=c(0,3))

qplot(carat, data=diamonds, geom="histogram", fill=color)

# Density

qplot(carat, data=diamonds, geom="density")

qplot(carat, data=diamonds, geom="density", colour=color)

qplot(carat, data=diamonds, geom="density", fill=color)

# Bar charts

qplot(color, data=diamonds, geom="bar")

qplot(color, data=diamonds, geom="bar", weight=carat)

qplot(color, data=diamonds, geom="bar", weight=carat) + scale_y_continuous("carat")

# Faceting

qplot(carat, data=diamonds, facets = color ~ .,
      geom="histogram", binwidth=0.1, xlim=c(0,3)) + scale_y_continuous("carat")

qplot(carat, ..density.., data=diamonds, facets = color ~ .,
      geom="histogram", binwidth=0.1, xlim=c(0,3)) 

# Scatterplots

summary(mpg)

qplot(displ, hwy, data=mpg)

qplot(displ, hwy, data=mpg) + geom_smooth(method="lm")

# by year

qplot(displ, hwy, data=mpg, facets = . ~ year) + geom_smooth(method="lm")

qplot(displ, hwy, data=mpg, facets = . ~ year) + geom_smooth()

# by cylinders

qplot(displ, hwy, data=mpg, colour=factor(cyl))

qplot(displ, hwy, data=mpg, colour=factor(cyl)) + geom_smooth(method="lm")

qplot(displ, hwy, data=mpg, colour=factor(cyl)) + geom_smooth()

qplot(displ, hwy, data=mpg, facets = . ~ year, colour=factor(cyl)) + geom_smooth()

### ACTIVITY 7

# Histogram matrix
library(lattice)
birth_yearly <- read.csv("birth-rate-yearly.csv")
histogram(~ rate | year, data=birth_yearly, layout=c(10,5))

birth_yearly.new <- birth_yearly[birth_yearly$rate < 132,]
birth_yearly.new$year <- as.character(birth_yearly.new$year)
h <- histogram(~ rate | year, data=birth_yearly.new, layout=c(10,5))
update(h, index.cond=list(c(41:50, 31:40, 21:30, 11:20, 1:10)))

### ACTIVITY 8
tvs <- read.table('tv_sizes.txt', sep="\t", header=TRUE)

tvs <- tvs[tvs$size < 80, ]
tvs <- tvs[tvs$size > 10, ]

breaks = seq(10, 80, by=5)

par(mfrow=c(4,2))
hist(tvs[tvs$year == 2009,]$size, breaks=breaks)
hist(tvs[tvs$year == 2008,]$size, breaks=breaks)
hist(tvs[tvs$year == 2007,]$size, breaks=breaks)
hist(tvs[tvs$year == 2006,]$size, breaks=breaks)
hist(tvs[tvs$year == 2005,]$size, breaks=breaks)
hist(tvs[tvs$year == 2004,]$size, breaks=breaks)
hist(tvs[tvs$year == 2003,]$size, breaks=breaks)
hist(tvs[tvs$year == 2002,]$size, breaks=breaks)
#hist(tvs[tvs$year == 2001,]$size, breaks=breaks)

### ACTIVITY 9
library(hts)

# Example 1
# The hierarchical structure looks like 2 child nodes associated with level 1,
# which are followed by 3 and 2 sub-child nodes respectively at level 2.

nodes <- list(2, c(3, 2))
abc <- ts(5 + matrix(sort(rnorm(500)), ncol = 5, nrow = 100))
x <- hts(abc, nodes)

# etc

fc <- forecast(x, h=10, fmethod="ets", parallel=TRUE, num.cores=2)

plot(fc)

# arima

fc <- forecast(x, h=10, fmethod="arima", parallel=TRUE, num.cores=4)

plot(fc)


# Example 2
# Suppose we've got the bottom names that can be useful for constructing the node
# structure and the labels at higher levels. We need to specify how to split them 
# in the argument "characters".

abc <- ts(5 + matrix(sort(rnorm(1000)), ncol = 10, nrow = 100))
colnames(abc) <- c("A10A", "A10B", "A10C", "A20A", "A20B",
                   "B30A", "B30B", "B40A", "B40B", "B40C")
y <- hts(abc, characters = c(1, 2, 1))

# etc

fc <- forecast(y, h=10, fmethod="ets", parallel=TRUE, num.cores=2)

plot(fc)

# arima

fc <- forecast(y, h=10, fmethod="arima", parallel=TRUE, num.cores=4)

plot(fc)









