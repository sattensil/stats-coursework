#3a.    Find a 95% simple bootstrapping confidence interval for the mean number of 
#particles emitted.Bootstrap 5000 times

data=c(4, 1, 3, 1, 3, 3, 3, 1, 1, 1, 6, 4, 4, 2, 2, 1, 1, 4, 2, 5)
B = 5000 #number of bootstrap samples
N=length(data)

bss= sample(data, B*N, replace = T)
bss_matrix= matrix(bss, nrow= B) 
sample_mean=mean(data)
bs_mean=rowMeans(bss_matrix) 
bs_sd=apply(bss_matrix,1,sd)
sample_sd=sd(data)
bs_t=(bs_mean-sample_mean)/(bs_sd/sqrt(N))
bs_tpercentile=quantile(bs_t,c(0.025,0.975))
lowerlimit=sample_mean+(bs_tpercentile[1]*sample_sd/sqrt(N))
upperlimit=sample_mean+(bs_tpercentile[2]*sample_sd/sqrt(N))
lowerlimit;upperlimit

bci= quantile(bs_mean, c(0.025, 0.975)) 
bci

#3.b)

##3.b)i.    Derive the posterior Gamma distributions and identify the parameters

sum(data)
length(data)

##3.b)i.i. Simulate the posterior distribution for ? in R
a=2
b=1
sim=rgamma(5000,a+sum(data),)
#theoretical mean
(a+sum(data))/((1/b)+length(data))


##3.b)i.ii.Give the posterior mean from the simulation
mean(sim)

##3.b)i.v.Plot both the prior and posterior densities by sampling from the prior and 
#posterior Gammas along with the likelihood function. You can use the 'density' function


lambda = seq(from = 0, to =4, by = .01)

a=2
b=1

plambda = dgamma(lambda,a,b)

pdatagivenlambda=exp(-length(data)*lambda)*lambda^(sum(data))/sum(factorial(data))

plambdagivendata= dgamma(lambda,a+sum(data),((1/b)+length(data)))


windows(10,10)
layout(matrix(c(1,2,3),nrow= 3, ncol= 1, byrow= FALSE))
maxy=max(c(plambda, plambdagivendata))

plot(lambda, plambda, type = "l", lwd= 3, main="Prior")
plot(lambda, pdatagivenlambda, type = "l", lwd= 3, main="Likelihood")
plot(lambda,plambdagivendata, type = "l", lwd= 3, main="Posterior")



windows(10,10)
layout(matrix(c(1,2,3),nrow= 2, ncol= 1, byrow= FALSE))

x = seq( -.01,  1,.01)
n=8197
y=51

a=1
b=1
prior <- dbeta(x,a,b)
posterior <- dbeta(x,a+y,b+n-y)
a+y
b+n-y
plot(x, prior, type="l", lty=2, xlab="x value", ylab="Density", main="Beta(1,1) Prior")
plot(x, posterior, type="l", lty=2, xlab="x value", ylab="Density", main="Beta(52,8147) Posterior")

#Expected value of p - prior
a/(a+b)

#Expected value of p - posterior
(a+y)/(a+b+n)


windows(10,10)
layout(matrix(c(1,2,3),nrow= 2, ncol= 1, byrow= FALSE))


x = seq( -.01,  1,.01)
n=8197
y=51

a=1
b=19
prior <- dbeta(x,a,b)
posterior <- dbeta(x,a+y,b+n-y)
a+y
b+n-y
plot(x, prior, type="l", lty=2, xlab="x value", ylab="Density", main="Beta(1,19) Prior")
plot(x, posterior, type="l", lty=2, xlab="x value", ylab="Density", main="Beta(52,8165) Posterior")

#Expected value of p - prior
a/(a+b)

#Expected value of p - posterior
(a+y)/(a+b+n)


