### Problem 46: Bowhead whale.

library(stats4)

# a.

whale = scan("C:\\whale\\whale.txt")		# read data

whale.data = whale

br = seq(0,5,0.25) 	# create breaks for the histogram

X11()
hist(whale,breaks=br,main='whale data',probability = T,plot=T)		# create histogram with breaks br

# since thew whale data is continuous, really should use a density estimator

#X11()
#plot(density(whale, n=50, window="g"),type="l",xlab="x",ylab="density")

########################################################################################
# matrices for output

out.mme = matrix(0,2,5)

out.mle = matrix(0,2,7)

########################################################################################
# b.  MME

n = length(whale) 	# sample size

x.bar = mean(whale)	# sample mean

sigmasq.hat = ((n-1)/n)*var(whale) 	# (1/n)sum(x_i - x.bar)^2

lambda.hat.mme = x.bar/sigmasq.hat
lambda.hat.mme

alpha.hat.mme = x.bar^2/sigmasq.hat
alpha.hat.mme

out.mme[1,1] = alpha.hat.mme
out.mme[2,1] = lambda.hat.mme

# c. MLE

# solve the nonlinear equation 

ll = function(alp,lam) { 
	-(n*alp*log(lam)+(alp-1)*sum(log(whale))-lam*sum(whale)-n*log(gamma(alp))) 
}

gamma.mle = mle(minuslog=ll,start=list(alp=1,lam=1)) 

alpha.hat.mle = coef(gamma.mle)[1]
alpha.hat.mle

lambda.hat.mle = coef(gamma.mle)[2]
lambda.hat.mle

out.mle[1,1] = alpha.hat.mle
out.mle[2,1] = lambda.hat.mle

# d. 

# plot the fitted density using mme

par(new=T)		# plot fitted curve on the histogram

x = seq(0.01,5,0.01)
y = dgamma(x,alpha.hat.mme,lambda.hat.mme)

y.max = 1.8		# approximate maximum of the histogram, used to match y-axis scale.

plot(x,y,type='l',ylim=c(0,y.max))

# plot the fitted density using mle

par(new=T)		# plot fitted curve on the histogram

x = seq(0.01,5,0.01)
y = dgamma(x,alpha.hat.mle,lambda.hat.mle)

y.max = 1.8		# approximate maximum of the histogram, used to match y-axis scale.

plot(x,y,type='l',lty=4,ylim=c(0,y.max))

# e. Bootstrap estimate of the s.e. and sampling distribution of the mme's

B = 1000

y = matrix(0,B,n)

lambda.star.mme = numeric(B)
alpha.star.mme = numeric(B)

for(i in 1:B){
	y[i,] = rgamma(n, alpha.hat.mme,lambda.hat.mme)
	x.bar = mean(y[i,])
	sigmasq.hat = ((n-1)/n)*var(y[i,]) 
	lambda.star.mme[i] = x.bar/sigmasq.hat
	alpha.star.mme[i] = x.bar^2/sigmasq.hat
}

br = seq(0,5,0.10) 	# create breaks for the histogram

X11()
hist(alpha.star.mme,breaks=br,probability = T,plot=T) 

alpha.star.mean = mean(alpha.star.mme)
alpha.star.mean
alpha.star.sd = sqrt(var(alpha.star.mme))
alpha.star.sd

out.mme[1,2] = alpha.star.mean
out.mme[1,3] = alpha.star.sd

alpha.LCL = quantile(alpha.star.mme, 0.025)
alpha.LCL
alpha.UCL = quantile(alpha.star.mme, 0.975)
alpha.UCL

out.mme[1,4] = alpha.LCL
out.mme[1,5] = alpha.UCL

X11()
hist(lambda.star.mme,breaks=br,probability = T,plot=T)

lambda.star.mean = mean(lambda.star.mme)
lambda.star.mean
lambda.star.sd = sqrt(var(lambda.star.mme))
lambda.star.sd

out.mme[2,2] = lambda.star.mean
out.mme[2,3] = lambda.star.sd

lambda.LCL = quantile(lambda.star.mme, 0.025)
lambda.LCL
lambda.UCL = quantile(lambda.star.mme, 0.975)
lambda.UCL

out.mme[2,4] = lambda.LCL
out.mme[2,5] = lambda.UCL

# f. Bootstrap estimate of the s.e. and sampling distribution of the mle's

B = 1000

y = matrix(0,B,n)

lambda.star.mle = numeric(B)
alpha.star.mle = numeric(B)

for(i in 1:B){
	y[i,] = rgamma(n, alpha.hat.mle,lambda.hat.mle)
	whale = y[i,]

	ll = function(alp,lam) { 
		-(n*alp*log(lam)+(alp-1)*sum(log(whale))-lam*sum(whale)-n*log(gamma(alp))) 
	} 

	gamma.mle = mle(minuslog=ll,start=list(alp=1,lam=1)) 

	alpha.star.mle[i] = coef(gamma.mle)[1]	# alpha
	lambda.star.mle[i] = coef(gamma.mle)[2]	# lambda
}

br = seq(0,5,0.05) 	# create breaks for the histogram

X11()
hist(alpha.star.mle,breaks=br,probability = T,plot=T) 

alpha.star.mean = mean(alpha.star.mle)
alpha.star.mean
alpha.star.sd = sqrt(var(alpha.star.mle))
alpha.star.sd

out.mle[1,2] = alpha.star.mean
out.mle[1,3] = alpha.star.sd

alpha.LCL = quantile(alpha.star.mle, 0.025)
alpha.LCL
alpha.UCL = quantile(alpha.star.mle, 0.975)
alpha.UCL

out.mle[1,4] = alpha.LCL
out.mle[1,5] = alpha.UCL

X11()
hist(lambda.star.mle,breaks=br,probability = T,plot=T)

lambda.star.mean = mean(lambda.star.mle)
lambda.star.mean
lambda.star.sd = sqrt(var(lambda.star.mle))
lambda.star.sd

out.mle[2,2] = lambda.star.mean
out.mle[2,3] = lambda.star.sd

lambda.LCL = quantile(lambda.star.mle, 0.025)
lambda.LCL
lambda.UCL = quantile(lambda.star.mle, 0.975)
lambda.UCL

out.mle[2,4] = lambda.LCL
out.mle[2,5] = lambda.UCL

# g. approximate 95% CI for the mle's

# alpha 

delta.low = quantile(alpha.star.mle,0.025) - alpha.star.mean 
delta.up = quantile(alpha.star.mle,0.975) - alpha.star.mean

mle.LCL = alpha.hat.mle - delta.up 
mle.LCL
mle.UCL = alpha.hat.mle - delta.low
mle.UCL

out.mle[1,6] = mle.LCL
out.mle[1,7] = mle.UCL

# lambda 

delta.low = quantile(lambda.star.mle,0.025) - lambda.star.mean 
delta.up = quantile(lambda.star.mle,0.975) - lambda.star.mean

mle.LCL = lambda.hat.mle - delta.up 
mle.LCL
mle.UCL = lambda.hat.mle - delta.low
mle.UCL

out.mle[2,6] = mle.LCL
out.mle[2,7] = mle.UCL

# Summary

dimnames(out.mme) = list(c("alpha","lambda"),c("MME", "Bootstrap.mean", "Bootstrap.sd", "quant.LCL", "quant.UCL"))
dimnames(out.mle) = list(c("alpha","lambda"),c("MLE", "Bootstrap.mean", "Bootstrap.sd", "quant.LCL", "quant.UCL", "approx.LCL", "approx.UCL"))

out.mme
out.mle
