setwd("C:/Users/Scarlett/Desktop/Time Series")
require("astsa")
beer <- ts(read.csv("ausbeer.csv", stringsAsFactors = FALSE), start = 1956, frequency = 4,deltat=1/4)
plot.ts(beer,ylab="megaliters",main="Fig. 1 - Australian Beer Production")
plot.ts(beer,ylab="megaliters",main="Australian Beer Production",xlim=c(1960,1961))

trend=time(beer)-1956
qtr=rep(1:4,53)
q=qtr[1:210]

#linear
fit1=lm(beer~0+trend+as.factor(q),na.action=NULL) 
summary(fit1)
summary(aov(fit1))
par(mfrow=c(1,1))
plot(beer)
lines(fit1$fitted, col="red")
acf(fit1$resid)

#2nd order polynomial
trend2=trend^2
fit2=lm(beer~0+trend+trend2+as.factor(q),na.action=NULL) 

#3rd order polynomial
trend3=trend^3
fit3=lm(beer~0+trend+trend2+trend3+as.factor(q),na.action=NULL) 

#4th order polynomial
trend4=trend^4
fit4=lm(beer~0+trend+trend2+trend3+trend4+as.factor(q),na.action=NULL) 

#5th order polynomial
trend5=trend^5
fit5=lm(beer~0+trend+trend2+trend3+trend4+trend5+as.factor(q),na.action=NULL) 
summary(fit5)
summary(aov(fit5))
par(mfrow=c(1,2))
plot(beer,main="Fig. 3 - 5th Order Polynomial with Quarterly Factor",ylab="megaliters")
lines(fit5$fitted, col="red")
acf(fit5$resid, main="Fig. 4 - 5th Order Residuals")
plot.ts(fit5$resid,main="Detrended") # still shows seasonal, wave like behavior

#6th order polynomial
trend6=trend^6
fit6=lm(beer~0+trend+trend2+trend3+trend4+trend5+trend6+as.factor(q),na.action=NULL) 

#7th order polynomial
trend7=trend^7
fit7=lm(beer~0+trend+trend2+trend3+trend4+trend5+trend6+trend7+as.factor(q),na.action=NULL) 
summary(fit7)
summary(aov(fit7))
plot(beer,main="Fig. 3 - 7th Order Polynomial with Quarterly Factor",ylab="megaliters")
lines(fit7$fitted, col="red")
acf(fit7$resid, main="7th Order Residuals")
plot.ts(fit7$resid,main="Detrended") # still shows seasonal, wave like behavior

#8th order polynomial
trend8=trend^8
fit8=lm(beer~0+trend+trend2+trend3+trend4+trend5+trend6+trend7+trend8+as.factor(q),na.action=NULL) 

#9th order polynomial
trend9=trend^9
fit9=lm(beer~0+trend+trend2+trend3+trend4+trend5+trend6+trend7+trend8+trend9+as.factor(q),na.action=NULL) 

#10th order polynomial
trend10=trend^10
fit10=lm(beer~0+trend+trend2+trend3+trend4+trend5+trend6+trend7+trend8+trend9+trend10+as.factor(q),na.action=NULL) 
summary(fit10)
summary(aov(fit10))
plot(beer,main="Fig. 2 - 10th Order Polnomial with Quarterly Factor",ylab="megaliters")
lines(fit10$fitted, col="red")
acf(fit10$resid, main="10th Order Residuals")
plot.ts(fit10$resid,main="Detrended") # still shows seasonal, wave like behavior

#Can you fit an ARIMA after polynomial detrending?
library('forecast')
auto.arima(fit5$resid)
fit.arimaX=sarima(fit5$resid,1,0,2,1,0,1,4)
fit.arimaX

R2=c(summary(fit1)$adj.r.squared,summary(fit2)$adj.r.squared,
     summary(fit3)$adj.r.squared,summary(fit4)$adj.r.squared,
     summary(fit5)$adj.r.squared,summary(fit6)$adj.r.squared,summary(fit7)$adj.r.squared,
     summary(fit8)$adj.r.squared,summary(fit9)$adj.r.squared,summary(fit10)$adj.r.squared)
par(mfrow=c(1,1))
ts.plot(R2, type="o",main="Fig. 2 - Polynomial Regression",xlab="Polynomial Order",ylab="Adjusted R Squared")



acf2(beer,16)
#ACF tails off PACF cuts off after lag ? 1,1.5 or 2
#suggest AR(4),AR(6),AR(8)?

plot(diff(beer))
#does not appear to be a trend after first difference

par(mfrow=c(1,1))
lag.plot(beer,4, labels=FALSE, main="Fig.5 - Lag Plot")
Fig.6.Diff.Beer = diff(beer)
acf2(Fig.6.Diff.Beer,16,main="Fig.6 - ACF/PACF of Diff(Beer)") 
#suggest AR(3),AR(6)
#acf strong annual, semi annual seasonal components PACF ends at 3 or 6


Fig.6.Diff.Diff.Beer.4 = diff(diff(beer),4)
acf2(Fig.6.Diff.Diff.Beer.4,16)
#Seasonal Lags
#ACF cutting off after 1, PACF tailing off => Q=1
#ACF and PACF both tailing off 

#Within seasonal lags
#PACF cuts off at lag 2 => p=2,q=0
#ACF cuts off at lag 3 => p=0,q=3
#ACF cuts off at lag 1 => p=0,q=1
#both tailing off => p=2,q=1
#ARIMA(0,1,2)(0,1,1)[4] 


require("forecast")
auto.arima(beer) #ARIMA(0,1,2)(0,1,1)[4] 

#ARIMA(0,1,q) X (0,1,1) [4]
n=length(beer)
AIC=rep(0,30)->AICc->BIC
for(k in 0:30)
  {
  fit=sarima(beer,0,1,k,0,1,1,4,details=FALSE) 
  BIC[k]=fit$BIC
  AICc[k]=fit$AICc
  AIC[k]=fit$AIC
}
IC=cbind(AIC,BIC+1) #Add 1 for graphing 

#ARIMA(2,1,q) X (0,1,1) [4]
n=length(beer)
AIC2=rep(0,30)->AICc2->BIC2
for(k in 0:30)
{
  fit=sarima(beer,2,1,k,0,1,1,4,details=FALSE) 
  BIC2[k]=fit$BIC
  AICc2[k]=fit$AICc
  AIC2[k]=fit$AIC
}
IC2=cbind(AIC2,BIC2+1)

par(mfrow=c(1,2))
ts.plot(IC,type="o",main = "Fig. 7 - SARIMA(0,1,q) X (0,1,1) [4]", xlab="q",ylab="AIC/BIC",xlim=c(0,2))
ts.plot(IC2,type="o",main = "Fig. 8 - SARIMA(2,1,q) X (0,1,1) [4]", xlab="q",ylab="AIC/BIC")

#To see diagnostics
fita=sarima(beer,0,1,2,0,1,1,4,details=FALSE) 
fitb=sarima(beer,2,1,1,0,1,1,4,details=FALSE) 
fitc=sarima(beer,2,1,7,0,1,1,4,details=FALSE) 

fore.a=sarima.for(beer,20,0,1,2,0,1,1,4)
fore.b=sarima.for(beer,20,2,1,1,0,1,1,4)
fore.c=sarima.for(beer,20,2,1,7,0,1,1,4)

a=c(fita$AIC,fitb$AIC,fitc$AIC)
b=c(fita$AICc,fitb$AICc,fitc$AICc)
c=c(fita$BIC,fitb$BIC,fitc$BIC)
d=cbind(a,b,c)
d

#Forecasts
par(mfrow=c(1,2))
plot(beer,xlim=c(2007,2010.5),main='Figure 11 - Forecasted Values',ylab='megaliters')
lines(fore.a$pred,col='red',lty='dotted')
lines(fore.b$pred,col='red',lty='dashed')
lines(fore.c$pred,col='blue',lty='dotted')


plot(fore.a$se,lty='dotted',main="Figure 12 - Standard Error",ylab="Standard Error")
lines(fore.b$se,col='red',lty='dashed')
lines(fore.c$se,col='blue',lty='dotted')



#Periodogram
nextn(length(beer))
par(mfrow=c(1,1))
beer.per=spec.pgram(diff(beer), taper=0, log='no')
abline(h=2*beer.per$spec[54]/L,col='red',lty='dotted')
abline(h=2*beer.per$spec[108]/L,col='blue',lty='dotted')
abline(h=2*beer.per$spec[55]/L,col='blue',lty='dotted')

#Calculates all Confidence Intervals in Decreasing order of Power
U=qchisq(.025,beer.per$df)
L=qchisq(.975,beer.per$df)

datapoint=order(beer.per$spec,decreasing=TRUE)
pwr=beer.per$spec[datapoint]
freq=beer.per$freq[datapoint]
lambda=1/beer.per$freq[datapoint]
max=beer.per$df*pwr/U
min=beer.per$df*pwr/L
signif=pwr-min>0
d=cbind(datapoint,pwr,freq,lambda,max,min,signif)
head(d,20)


spectrum(diff(beer),freq=1, taper=0)


#Frequency domain model
fit.fd=arima(beer,order=c(0,1,2) ) # -1.5771  0.9128
fit.fd
ARMAacf(ar = 0, ma = c(-1.5771, 0.9128))
#0          1          2          3 
# 1.0000000 -0.6982324  0.2112744  0.0000000 

omega=fft(diff(beer))
t=time(beer)-1956
q=2*-0.6982324*cos(2*pi*t)
r=2*0.2112744*cos(4*pi*t)
tran=(1+q+r)
plot(tran,type='l',ylab="")
     ,yaxt='n')

#looking at the Frequency domain model

fit.fd=arima(beer,order=c(0,1,2) ) # -1.5771  0.9128
arma.spec(ma= c(-1.5771, 0.9128),log='no', main='Spectrum using the ARIMA(0,1,2) Model')

fit.fd=arima(beer,order=c(2,1,1) ) #-0.1800  -0.7163  -0.6846
fit.fd
arma.spec(ar=c(-0.1800,-0.7163),ma=-0.6846,log='no', main='Spectrum using the ARIMA(2,1,1) Model')


plot.ts(diff(beer))

f.beer=SigExtract(diff(beer))


#MA(3) Models
acf2(diff(beer))
#Least Squared Prediction
regr=ar.ols(diff(beer), order=3,demean=FALSE,intercept=TRUE)
regr
regr$asy.se.coef
fore=predict(regr,n.ahead=8)
ts.plot(diff(beer), fore$pred, col=1:2,xlim=c(1956,2012))
lines(fore$pred,col=2)
fore

#Yule-Walker Prediction
yw=ar.yw(diff(beer), order=3)
yw
yw.fore=predict(yw,n.ahead=8)
ts.plot(diff(beer), yw$pred, col=1:2,xlim=c(1956,2012))
lines(yw.fore$pred,col=2)
yw.fore

#MLE Prediction
mle=ar.mle(diff(beer), order=3)
mle
mle.fore=predict(mle,n.ahead=8)
ts.plot(diff(beer), mle$pred, col=1:2,xlim=c(1956,2012))
lines(ple.fore$pred,col=2)
yw.fore









