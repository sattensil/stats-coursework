#4
cl=.95
#built in
prop.test(800, 1000, .8,alternative = "two.sided",conf.level = cl)
binom.test(800, 1000, .8, alternative = "two.sided",conf.level = cl)

prop.test(800, 1000, .8,alternative = "two.sided",conf.level = cl, correct=TRUE)

#wald
pi=.8
s=(.8*.2/n)^.5

pi-qnorm(1-(1-cl)/2)*s
pi+qnorm(1-(1-cl)/2)*s

#WAC 
pi=(800+.5*qnorm(1-(1-cl)/2)^2)/(1000+qnorm(1-(1-cl)/2)^2)
s=(pi*(1-pi)/(1000+qnorm(.95)^2))^.5
pi-qnorm(1-(1-cl)/2)*s
pi+qnorm(1-(1-cl)/2)*s

 #6
 cl=.95
 y=591
 n=11000
 #built in
 prop.test(y, n, .05,alternative = "less",conf.level = cl)
 
 #wald
 pi=y/n
 s=(y/n*(1-y/n)/n)^.5
 
 pi-qnorm(1-(1-cl)/2)*s
 pi+qnorm(1-(1-cl)/2)*s

prop.test(y, n, .05,alternative = "two.sided",conf.level = cl, correct=FALSE)
prop.test(y, n, .05,alternative = "two.sided",conf.level = cl)
 
 
#14
cl=.95
y=424
n=800
#built in
prop.test(y, n, .5, alternative = "greater",conf.level = cl)
binom.test(y, n, .5, alternative = "greater",conf.level = cl)
prop.test(y, n, .5, alternative = "two.sided",conf.level = cl, correct=FALSE)

#wald
pi=y/n
s=(y/n*(1-y/n)/n)^.5

pi-qnorm(1-(1-cl)/2)*s
pi+qnorm(1-(1-cl)/2)*s

#WAC 
pi=(y+.5*qnorm(1-(1-cl)/2)^2)/(n+qnorm(1-(1-cl)/2)^2)
s=(pi*(1-pi)/(n+qnorm(.95)^2))^.5
pi-qnorm(1-(1-cl)/2)*s
pi+qnorm(1-(1-cl)/2)*s

#16
n1=500
n2=400
pi1=.3
s1=pi1*(1-pi1)/n1

pi2=.1
s2=pi2*(1-pi2)/n2

m=pi1-pi2
m
s=(s1+s2)^.5
s

pi1*n1 <5
(1-pi1)*n1 <5
pi2*n2 <5
(1-pi2)*n2 <5


#18
cl=.95

y1=91
n1=250

y2=53
n2=250

pi1=y1/n1
s1=pi1*(1-pi1)/n1

pi2=y2/n2
s2=pi2*(1-pi2)/n2

m=pi1-pi2
m
s=(s1+s2)^.5
s

m-qnorm(1-(1-cl)/2)*s
m+qnorm(1-(1-cl)/2)*s

prop.test(c(y1,y2),c(n1,n2),alternative = "two.sided", conf.level=cl,correct=FALSE)

prop.test(c(y1,y2),c(n1,n2),alternative = "greater")

#22
cl=.95

y1=171
n1=200

y2=153
n2=200

pi1=y1/n1
s1=pi1*(1-pi1)/n1

pi2=y2/n2
s2=pi2*(1-pi2)/n2

m=pi1-pi2
m
s=(s1+s2)^.5
s

m-qnorm(1-(1-cl)/2)*s
m+qnorm(1-(1-cl)/2)*s

prop.test(c(y1,y2),c(n1,n2),alternative = "two.sided", conf.level=cl, correct=FALSE)

prop.test(c(y1,y2),c(n1,n2),alternative = "greater")

#28
d<-c(328,372,471,329)
h<-rep(.25,4)
chisq.test(x=d,p=h)
qchisq(.95,3)

#33
d<-c(399,231,158,212)
barplot(d, ylab='count', main='10.33')
h<-rep(.25,4)
chisq.test(x=d,p=h)
qchisq(.95,3)

#41 
a=c(58.33,33.33,8.33)
g=c(4.69,39.06,56.25)
m=c(46.67,44.44,8.89)
u=c(43.48,30.43,26.09)

barplot(cbind(a,g,m,u))
legend("topright",legend=c("Most Desireable","Good","Adequate","Undesireable"))

#45
d<-matrix(c(39+55+30,92+69+77,19+22+24,114+88+83),nrow=2,ncol=2)
chisq.test(x=d)




