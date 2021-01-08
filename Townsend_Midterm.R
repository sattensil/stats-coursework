#Problem 1
#Does the number of defective phones produced by apple follow ar Poisson distribution?

n=630 #size of random sample - number of days
Defective=c(0,1,2,3,4) #Note: 4 = 4 or more
O=c(191,228,141,51,19)
x=as.data.frame(cbind(Defective,O))
attach(x)
plot(x,type="h",ylab="Observed Days", xlab="Number Defective")

#H0: The number of defective phones is Poisson distributed 
#vs H1: The number of defective phones follows a different distribution

sum(x$Defective*x$O)/n

lik=function(lambda){
  suml=dmultinom(x$O,n,c(dpois(0:3,lambda),1-ppois(3,lambda)))
  return (suml)}

mle=optimize(lik,c(1,2),maximum=TRUE)

d=c(dpois(0:3,mle$maximum),1-ppois(3,mle$maximum))
sum(d)
x$E=d*n
x$E

qchisq(.95,4)

P=sum((x$O-x$E)^2/x$E)
1-pchisq(P,4)

D=2*sum(x$O*log(x$O/x$E))
1-pchisq(D,4)

########################################################################################
#Problem 2
#Is the sample from a Gamma(3,5) distribution or a Gamma(3,B) distribution where B>5?
set.seed(1979)
s=rgamma(100,3,scale=5)
m=mean(s)
m
Bmle=m/3
Bmle

qgamma(.95,3*length(s),scale=5)

pgamma(sum(s),3*length(s),scale=5)

1-pgamma(qgamma(.95,3*length(s),scale=5),3*length(s),scale=6)


t=1:1000
for (i in 1:1000) {
  s=rgamma(100,3,scale=5)
  m=mean(s)
  t[i]=pgamma(sum(s),3*length(s),scale=5)>.95
}

sum(t)/10 #percent of the tests that were rejected

Beta1=seq(5,6.5,.1)
Power=1-pgamma(qgamma(.95,3*length(s),scale=5),3*length(s),scale=Beta1)
plot(Beta1,Power, type="l",main="Graph 1: Power as a function of Beta1")
abline(a=.8,b=0,col='red')

pwr=function(B) {
  x=ifelse (pgamma(qgamma(.95,3*length(s),scale=5),3*length(s),scale=B) > .2
            ,0,pgamma(qgamma(.95,3*length(s),scale=5),3*length(s),scale=B))
  return(x)}

B.8=optimize(pwr,c(5,7),maximum=TRUE,tol = 0.0000001)
B.8$maximum
1-pgamma(qgamma(.95,3*length(s),scale=5),3*length(s),scale=B.8$maximum)



