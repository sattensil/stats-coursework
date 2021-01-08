#######################
#
#  This script illustrates the calculation
#  of linear compunds and the calculation of
#  sample covariance matrices.
#
######################

library(mvtnorm)

###    define a covariance matrix

sigma = matrix(c(4,-2,3,-2,5,1,3,1,7),ncol=3)
print(sigma)

a     = c(2,3,-1)

theoretical.var.y = t(a) %*% sigma %*% a
print(theoretical.var.y)

###    generate many random vectors with this correlation matrix

n  = 50000    # number of vectors
mu = c(5,9,7)

x  = rmvnorm(n,mu,sigma)
dim(x)

sample.mu = colMeans(x)
print(sample.mu)

sample.cov = cov(x)
print(sample.cov)

####  now we illustrate the details of how the sample covariance is calculated.
#     (1) we subtract the mean from each variate.
#     (2) we multiply the demeaned columns together, sum that result, divide by n-1
our.sample.cov = matrix( rep(0,9),ncol = 3)  # allocate memory
x.zero.mean = cbind(x[,1]-sample.mu[1],x[,2]-sample.mu[2],x[,3]-sample.mu[3])
for ( i in 1:3)
  {                # i loop
     for ( j in 1:3 )
       {             # j loop
          our.sample.cov[i,j] = (1/(n-1))*sum(x.zero.mean[,i]*x.zero.mean[,j])
       }             # j loop
  }                # i loop

print(our.sample.cov)

###   form n instances of t(a)*x

a.mat = matrix( rep(a,n),byrow = TRUE, ncol = 3)
y     = rowSums(a.mat*x)

var(y)

theoretical.var.y = t(a) %*% sigma %*% a
print(theoretical.var.y)

mean(y)

theoretical.mean.y = sum(a*mu)
print(theoretical.mean.y)

 




