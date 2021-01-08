#Scarlett Townsend
#STAT 6502 - Spring 2016
#Homework #4
#Ch11 - 1,2,3,8,15,16,19,32,34,39
####################################################
# Ch.11 - 1

x=c(1.1650,.6268,.0751,.3516)
y=c(.3035,2.6961,1.0591,2.7971,1.2641)
nx=length(x)
ny=length(y)
##1.a
mx=mean(x)
  mx
my=mean(y)
  my
mxy=mx-my
  mxy

##1.b
vx=(sd(x))^2
  vx
vy=(sd(y))^2
  vy
vp=((nx-1)*vx+(ny-1)*vy)/(nx+ny-2)
  vp

##1.c
sp=(vp*((1/nx)+(1/ny)))^.5
  sp

##1.d confidence interval
alpha = .1
lb = mxy-qt(1-alpha/2,nx+ny-2)*sp
  lb
ub = mxy+qt(1-alpha/2,nx+ny-2)*sp
  ub
##1.f p-value
t=mxy/sp
2*pt(t,nx+ny-2)

#check
t.test(x,y,var.equal=TRUE,conf.level = 0.9)

##1.g hypothesis test
abs(t)>qt(1-alpha/2,nx+ny-2)

##1.h
alpha = .1
v=1
s=(v*((1/nx)+(1/ny)))^.5
### confidence interval
lb = mxy-qnorm(1-alpha/2,0,s)
lb
ub = mxy+qnorm(1-alpha/2,0,s)
ub
### p-value
pnorm(mxy,0,s)
### hypothesis test
abs(mxy)>qnorm(1-alpha/2,0,s)
####################################################
# Ch.11 - #19

n=m=25
v = 25  # true population variances
##19.a std error
s=(v*((1/n)+(1/m)))^.5
s
##19.b RR
alpha = .05
qnorm(1-alpha,0,s)
##19.c Power
mxy=1
1-pnorm(qnorm(1-alpha,0,s),mxy,s)

##19.e RR
alpha = .05
lb = -qnorm(1-alpha/2,0,s)
lb
ub = qnorm(1-alpha/2,0,s)
ub
### Power
mxy=1
1-pnorm(qnorm(1-alpha/2,0,s),mxy,s)
####################################################
# Ch.11 - 34
n=m=25
v = 100  # true population variances
D=seq(-5,15,.01)
##34.a
r=50/(v)
sd=((2*v*(1-r))/n)^.5
sd
sd=((2*v-2*c)/n)^.5
sd
pa=1-pnorm(qnorm(1-alpha/2,0,sd),D,sd)
##34.b
s=(v*((1/n)+(1/m)))^.5
s
pb=1-pnorm(qnorm(1-alpha/2,0,s),D,s)

plot(D,pb,type="l")
lines(D,pa,col="red")
####################################################
# Ch.11 - 39
test=c(676,206,230,256,280,433,337,466,497,512,794,428,452,512)
control=c(88,570,605,617,653,2913,924,286,1098,982,2346,321,615,519)
diff=test-control
data=cbind(test,control,diff)
##39.a
plot(control,diff)
m=mean(diff)
m
s=sd(diff)
s
### Confidence Interval
alpha = .05
lb = qnorm(alpha/2,m,s)
lb
ub = qnorm(1-alpha/2,m,s)
ub


