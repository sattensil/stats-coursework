
#scarlett Townsend 
#HW 4

require("astsa")
require("forecast")

# Problem 3.31
plot(gnp)
acf2(gnp,50)
gnpgr=log(gnp) #growth rate
plot(gnpgr)
acf2(gnpgr,24)

gnpgr.fit=sarima(gnpgr,0,1,2) #MA(2)
gnpgr.fit

gnpgr2.fit=sarima(gnpgr,1,1,0) #AR(1)
gnpgr2.fit

# Problem 3.32

plot(oil)
acf2(oil,50) #shows PACF is cutting off at lag 1, ACF is tailing off - suggests AR(1)
auto.arima(oil) #sugests ARIMA(1,1,3)(0,0,1)[52]  

oilgr=log(oil)
plot(oilgr) 
acf2(oilgr,24) #shows PACF is cutting off at lag 1, ACF is tailing off - suggests AR(1)
auto.arima(oilgr) #sugests ARIMA(3,1,0)(1,0,1)[52] 

oilgr2=diff(log(oil))
plot(oilgr2) 
acf2(oilgr2,24) #shows PACF, ACF significant until 3
auto.arima(oilgr2) #sugests ARIMA(3,0,0)(1,0,1)[52] with zero mean consistent with above


oilgr.fit1=sarima(oilgr,0,1,3) 
oilgr.fit1 #this appears to be the best fit despite auto.arima

oilgr.fit2=sarima(oilgr,3,1,0) #auto.arima suggested
oilgr.fit2

oilgr.fit3=sarima(oilgr,3,1,3)
oilgr.fit3


# Problem 3.33

plot(gtemp)
acf2(gtemp,50) #shows PACF is cutting off at lag 1-4?, ACF is tailing off - suggests AR(1)
auto.arima(gtemp) #sugests (0,1,2) with drift

gtemp2=diff(gtemp)
plot(gtemp2) 
acf2(gtemp2,24) #shows PACF significant to 3, ACF tailing off, significant 1-4?
auto.arima(gtemp2) #sugests (0,0,2)

gtemp.fit=sarima(gtemp,0,1,2) 
gtemp.fit
sarima.for(gtemp,10,0,1,2)

# Problem 3.36
phi=c(rep(0,11),.8)
ACF=ARMAacf(ar=phi,ma=.5,0)[-1]
PACF=ARMAacf(ar=phi, ma=.5,50,pacf=TRUE)
par(mfrow=c(1,2))
plot(ACF,type="h",xlab="lag",ylim=c(-.4,.8)); abline(h=0)
plot(PACF,type="h",xlab="lag",ylim=c(-.4,.8)); abline(h=0)

# Problem 3.37
par(mfrow=c(1,1))
plot(unemp) #obvious trend
acf2(unemp,48)
plot(diff(unemp))#seems more spread out toward end
acf2(diff(unemp),48) 
acf2(diff(diff(unemp),12),48) #PACF and ACF cut off at 2, ACF cuts off after 1s, PACF tailing off
auto.arima(log(unemp)) #ARIMA(2,1,2)(1,0,0)[12] 
plot(diff(log(unemp)))
auto.arima(diff(log(unemp))) #ARIMA(2,0,2)(1,0,0)[12] with zero mean   
fit.unemp1=sarima(log(unemp),2,1,2,1,0,0,12) #suggested model
fit.unemp1
fit.unemp2=sarima(log(unemp),2,1,2,1,1,0,12)
fit.unemp2
fit.unemp3=sarima(log(unemp),2,1,0,0,1,1,12) #no residuals acf spike
fit.unemp3
fit.unemp4=sarima(log(unemp),2,1,0,0,1,3,12) #better than previous
fit.unemp4
fit.unemp5=sarima(log(unemp),2,1,0,2,1,1,12) 
fit.unemp5

par(mfrow=c(2,1))
fit.for=sarima.for(log(unemp),12,2,1,2,1,0,0,12)

fit.for2=sarima.for(log(unemp),12,2,1,0,0,1,3,12)

n=exp(fit.for$pred)
u=exp(fit.for$pred+fit.for$se)
l=exp(fit.for$pred-fit.for$se)
plot(unemp,xlim=c(1970,1980))
lines(n,col='red',type='o')
lines(u,col='blue',lty='dashed')
lines(l,col='blue',lty='dashed')

n2=exp(fit.for$pred)
u2=exp(fit.for$pred+fit.for$se)
l2=exp(fit.for$pred-fit.for$se)
plot(unemp,xlim=c(1970,1980))
lines(n2,col='red',type='o')
lines(u2,col='blue',lty='dashed')
lines(l2,col='blue',lty='dashed')






