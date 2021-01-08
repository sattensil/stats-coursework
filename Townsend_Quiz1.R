#1  50 catastrophic events
  ##a. 5-numbersummary and box plot.
ins = scan("C:/Users/Scarlett/Desktop/insurance.txt", sep =" ")
boxplot(ins,main = "1 - Insurance Losses")
summary(ins)
  #b. Comment on your observations.

#2. Rearview
  #a. Create a histogram with 10 classes.
rv = scan("C:/Users/Scarlett/Desktop/rearview.txt", sep =" ")
summary(rv)
hist(rv, breaks=seq(min(rv),max(rv),by=(max(rv)-min(rv))/10),probability = TRUE,col="pink", main= "2 - Rearview")
  #b. Comment on the shape of the histogram

#3. San Diego Freeway
  ##a. Calculate the sample means and sample standard deviations for both data set.
C_1976= scan("C:/Users/Scarlett/Desktop/lead1996.txt", sep =" ")
C_1977= scan("C:/Users/Scarlett/Desktop/lead1997.txt", sep =" ")
mean(C_1976)
sd(C_1976)
mean(C_1977)
sd(C_1977)
  ##b. Draw box plots to compare the lead concentration levels for both sites.
both=cbind(C_1976,C_1977)
boxplot(both, main = "3 - Lead Concentrations")

#4. Generate a random sample of size 5000 from an exponential distribution with theta = 5
#   and plot the histogram of these values.
set.seed(1)
exp=rexp(5000,1/5)
hist(exp,probability = TRUE,breaks = 100,col="mediumslateblue", main= "3 - Sample")
x <- seq(0, 40, length=10000)
hx <- dexp(x, 1/5, log = FALSE)
lines(x, hx, type="l")
  #a. Now draw random samples of size 40 (n) from this simulated data and create a
  #histogram for the sample when for 1000 simulations.
exp.sample.mean=rep(0,1000)
exp.sample.sd=rep(0,1000)
set.seed(1)
for(i in 1:1000)
{
  exp.sample=sample(exp,40) 
  exp.sample.mean[i]=mean(exp.sample) 
  exp.sample.sd[i]=sd(exp.sample)
}
hist(exp.sample.mean, probability = TRUE, col = "cyan2", breaks=30,main = "4 - Exponential Means") 
  #b. Compare the sample mean and the theoretical mean.
mean(exp)

x <- seq(2, 8, length=10000)
hx <- dnorm(x, mean = 5, sd = 5/(40^.5), log = FALSE)
lines(x, hx, type="l")
  #c. Also compare the sample variance with the theoretical variance.
  #(Use option set.seed(1) before you generate your sample)
sd(exp)


