#Scarlett Townsend
#STAT 6555
#Homework 1
#Chapter 1 - 1,2,4,7,19,22,23

#1.1 Earthquake and Explosion
require(astsa)
par(mfrow=c(2,1))
plot.ts(EQ5, main="1.1", xlab="",ylab="")
lines(EXP6, col = "red", lty = "dashed")

#1.2(a) Explosion
s = c(rep(0,100),10*exp(-(1:100)/20)*cos(2*pi*1:100/4))
x=ts(s + rnorm(200, 0, 1))
plot.ts(x, main="1.2(a)", xlab="",ylab="")

#1.2(b) arthquake
s = c(rep(0,100),10*exp(-(1:100)/200)*cos(2*pi*1:100/4))
y=ts(s + rnorm(200, 0, 1))
plot.ts(y, main="1.2(b)", xlab="",ylab="")

#1.2(c)
s = c(exp(-(1:100)/20))
x=ts(s + rnorm(100, 0, 1))
t = c(exp(-(1:100)/200))
y=ts(t + rnorm(100, 0, 1))
plot.ts(x, main="1.2(c)", xlab="",ylab="")
lines(y, col = "red", lty = "dashed")

plot.ts(s)
lines(t, col="red")

#1.22 Cyclical Oscillating ACF
s = c(rep(0,100),10*exp(-(1:100)/20)*cos(2*pi*1:100/4))
x=ts(s + rnorm(200, 0, 1))
plot(acf(x),main="1.22")

#1.23 signal plus noise
cs= 2*cos(2*pi*1:500/50 + .6*pi)
w= rnorm(500,0,1)
par(mfrow=c(3,1))
plot.ts(cs,main="1.23 Signal")
plot.ts(cs+w,main="1.23 Signal + Noise")
acf(cs+w,100)

#2.1 x.t=B.t+a.1Q.1(t)+a.2Q.2(t)+a.3Q.3(t)++a.4Q.4(t)+w.t
#jj - quarterly earnings starting in 1970
trend=time(jj) - 1970
Q=factor(rep(1:4,21)) #make quarter factors
reg=lm(log(jj)~0 + trend +Q, na.action=NULL) #no intercept
model.matrix(reg)
summary(reg)

reg2=lm(log(jj)~ trend +Q, na.action=NULL) #no intercept
model.matrix(reg2)
summary(reg2)

plot(log(jj),type='p',main="2.1")
lines(reg$fitted.values,type='p', col="red")
plot(reg$residuals)
plot(resid(reg))
acf(resid(reg))

#2.3 random walk with drift =.01 and sigma = 1
par(mfcol=c(3,2), mar = c(1,2,1,1))
for (i in 1:6) {
  x=ts(cumsum(rnorm(100,.01,1)))
  reg=lm(x~0+time(x),na.action=NULL)
  plot.ts(x)
  lines(.01*time(x),col="red",lty="dashed")
  abline(reg,col="blue")}

#2.11(a) For abs(p) close to zero, log(1+p)~p.  Let p=(y.t-y.t-1)/y.t-1
par(mfcol=c(1,1),mar = c(2,4,1,4))
plot.ts(gas, main="2.11",ylab="gas - cents/gallon")
par(new=TRUE)
plot.ts (oil, col = "red",xaxt="n",yaxt="n",xlab="",ylab="")
axis(4)
mtext("oil - $/barrel",side=4,line=3)

#2.11(c)
poil= diff(log(oil))
pgas=diff(log(gas))
plot.ts (pgas,main="2.11")
par(new=TRUE)
plot.ts (poil, col = "red",xaxt="n",yaxt="n",xlab="",ylab="")
legend("topleft",col=c("black","red"),lty=1,legend=c("delta gas","delta oil"))
acf(poil,lag.max=100)
acf(pgas,lag.max=100)

#2.11(d)
ccf(poil,pgas)

#2.11(e)
lag2.plot(poil,pgas,3)

#2.11(f)
#G.t=a.1+a.2I.t+B.1O.t+B.2O.t-1+w.t
#Growth rates, I=1 if O.t>0
indi= ifelse(poil<0,0,1)
mess= ts.intersect(pgas,poil,poilL=lag(poil,-1),indi)
summary(fit<-lm(pgas~poil+poilL+indi,data=mess))
acf(fit$residuals)


