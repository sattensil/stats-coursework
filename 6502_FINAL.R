# Scarlett Townsend
# STAT 6502 - FINAL EXAM

#### Problem 1 #####

alpha = .05
pnull = .5

# Find alpha <= .05 
n = 96
1- pbinom(55,n,pnull)
1- pbinom(56,n,pnull)

# Power Curve
p1=seq(.5,1,length=1000)
power = 1- pbinom(56,n,p1)
plot(p1,power,type="l",main="Figure 1 - Power Curve, Problem 1")

# Power = .8
powerfun=function(p){
  abs(1- pbinom(56,n,p)-.8)
}
optimize(powerfun,c(.6,.7),tol = 0.000001)
#verify
1- pbinom(56,n,0.6298893)

#### Problem 2 #####
data=c(3,2,3,1,0,0,2,1,3,2,1,1,0,2,0,2,2,1,3,2,1,0,2,3,1,0)

obs=as.matrix(table(data))
obs

n=length(data)
n
theta = (x[1,1]+x[2,1])/n
exp=c((2*theta)/3,(theta)/3, 2*(1-theta)/3, (1-theta)/3)*n
names(exp)=c("0", "1", "2", "3")  
exp

# numeric method
lik=function(theta){
  l=dmultinom(obs,prob=c((2*theta)/3,(theta)/3, 2*(1-theta)/3, (1-theta)/3))
  return(l)
}

mle=optimize(lik,c(0,1),maximum=TRUE)
mle

theta=seq(.00,1,.01)
liklihood=rep(0,101)
for(i in 1:101)(
liklihood[i]=dmultinom(obs,prob=c((2*theta[i])/3,(theta[i])/3, 2*(1-theta[i])/3, (1-theta[i])/3)))
plot(theta,liklihood,type="l")

# formula
theta=seq(.001,1,.001)
l=numeric(1000)
for(i in 1:1000){
p=c((2*theta[i])/3,theta[i]/3, 2*(1-theta[i])/3, (1-theta[i])/3);
l[i]=log(factorial(sum(obs)), base = exp(1))-sum(log(factorial(obs),base=exp(1)))+sum(obs*log(p, base = exp(1)))
}

plot(theta,exp(l),type="l",main="Figure 2 - Liklihood, Problem 2",ylab="liklihood")

T= 2*sum(obs*log(obs/exp, base = exp(1)))
1-pchisq(T,2)
qchisq(.95,2)



