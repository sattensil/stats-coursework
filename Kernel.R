# Kernel estimate of f

n <- 100
x <- rchisq(n,8)
#h <- 1
h <- c(0.5, 1, 5)
t <- seq(0,25, length=n)
fhat1 <- matrix(0, nrow=n, ncol=length(h))

plot(t, dchisq(t,8), type='l')

for (j in 1:length(h)){
	for (i in 1:n){
		fhat1[i,j] = 1/(n*h[j])*sum(dnorm((t[i]-x)/h[j]))
		}
	lines(t, fhat1[,j], xlab='x', ylab='', col=j+1)
	}
	
	
# Alternatively

#plot(density(x))

# or 

library(KernSmooth)

#fhat3 <- bkde(x)
#plot(fhat3, xlab='x', ylab='',type='l')
#lines(t, dchisq(t,8), col='red')