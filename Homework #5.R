# Scarlett Townsend 
# Time Series HW#5
 
# Problem 4.1
# 4.1 (a)
require('astsa')
par(mfcol=c(2,2))
x1=2*cos(2*pi*1:128*6/100)+3*sin(2*pi*1:128*6/100)
x2=4*cos(2*pi*1:128*10/100)+5*sin(2*pi*1:128*10/100)
x3=6*cos(2*pi*1:128*40/100)+7*sin(2*pi*1:128*40/100)
x=x1+x2+x3

y1=2*cos(2*pi*1:100*6/100)+3*sin(2*pi*1:100*6/100)
y2=4*cos(2*pi*1:100*10/100)+5*sin(2*pi*1:100*10/100)
y3=6*cos(2*pi*1:100*40/100)+7*sin(2*pi*1:100*40/100)
y=y1+y2+y3

plot.ts(x1,ylim=c(-10,10), main=expression(omega==6/100~~A^2==13))
plot.ts(x2,ylim=c(-10,10), main=expression(omega==10/100~~A^2==41))
plot.ts(x3,ylim=c(-10,10), main=expression(omega==40/100~~A^2==85))
plot.ts(x,ylim=c(-16,16), main="sum")

par(mfcol=c(1,1))
plot.ts(x,ylim=c(-16,16), main="sum")
lines(y, col="red")

# These series differ from the series generates in example 4.1 
# by their means and variances as the number of observations differ.

mean(x1)-mean(y1)
sd(x2)-sd(y2)

mean(x)-mean(y)
sd(x)-sd(y)

#4.1 (b)
par(mfcol=c(1,1))
P=abs(2*fft(x)/128)^2
Fr=0:127/128
plot(Fr,P,type="o",xlab="frequency",ylab="periodogram")

# As with example 4.2, the periodogram clearly identifies three distinct
# components,x1,x2 and x3, with a mirror effect seen at the folding frequency.

# 4.1 (c)
par(mfcol=c(2,2))
x1.2=2*cos(2*pi*1:100*6/100)+3*sin(2*pi*1:100*6/100)
x2.2=4*cos(2*pi*1:100*10/100)+5*sin(2*pi*1:100*10/100)
x3.2=6*cos(2*pi*1:100*40/100)+7*sin(2*pi*1:100*40/100)
x.2=x1.2+x2.2+x3.2+rnorm(100,0,5)
plot.ts(x1.2,ylim=c(-10,10), main=expression(omega==6/100~~A^2==13))
plot.ts(x2.2,ylim=c(-10,10), main=expression(omega==10/100~~A^2==41))
plot.ts(x3.2,ylim=c(-10,10), main=expression(omega==40/100~~A^2==85))
plot.ts(x.2,ylim=c(-16,16), main="sum")

par(mfrow=c(2,1))
plot.ts(x,ylim=c(-16,16), main="sum")
plot.ts(x.2,ylim=c(-16,16), main="sum")

par(mfcol=c(1,1))
P.2=abs(2*fft(x.2)/100)^2
Fr.2=0:99/100
plot(Fr.2,P.2,type="o",xlab="frequency",ylab="periodogram")

# While the two of the three components are still clearly visible, noise
# is now obsuring x1 as the periodigram is showing 2 or 3 peaks similar to the
# one now wittnessed at .06 between .1 and .3.

#Problem 4.8
par(mfrow=c(1,1))
plot(sunspotz,xlim=c(1950,1970))
sun.per=spec.pgram(sunspotz,taper=0,log="no")

abline(v=1/10.5,lty="dotted")
abline(v=1/75,lty="dotted")

# confidence intervals
nextn(459) #480

a=sun.per$spec[480/10.5] #246.0285 at 1/10.5
b=sun.per$spec[480/75] # 2,263.677 at 1/75
U=qchisq(.025,2)
L=qchisq(.975,2)
2*a/L #66.69465
2*a/U #9717.607

2*b/L #613.6489
2*b/U #89410.46

# For the 1/10.5 cycle, the CI is (66.69465, 9,717.607)
# For the 1/10.5 cycle, the CI is (613.6489, 89,410.46)

#Problem 4.21
require('astsa')
w=rnorm(504,0,1) 
v=filter(w,c(1,4,6,4,1), sides=2 ) 
v=v[3:502]
plot.ts(v)
v.per=spec.pgram(v,taper=0,log="no")
v.per
curve(70+112*cos(2*pi*x)+24*cos(4*pi*x), xlim=c(0,.5))




