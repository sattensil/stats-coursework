#Ex 1.1 J&J Quarterly EPS
  #quarterly variation superimposed on primary trend
require(astsa)
par(mfcol=c(1,1),mar = c(2,4,1,4))
plot(jj,type="o",ylab="Quarterly Earnings Per Share")

#Ex 1.2 GLOBAL WARMING
  # deviations in degrees C from the average global mean land-ocean temperature index
  #apparent trend upward with periodicities
plot(gtemp,type = "o",ylab="Global Temperature Deviations")

  #2.1 Estimating a Linear Trend - assume errors iid
    #Highly significant
  par(mfcol=c(1,1),mar = c(2,4,1,4))
  summary(fit<-lm(gtemp~time(gtemp)))
  plot(gtemp,type="o",ylab="Global Temperature Deviation")
  abline(fit)

  #2.4 Detrending Global Temperature
  fit=lm(gtemp~time(gtemp),na.action=NULL) 
  par(mfrow=c(2,1))
  plot(resid(fit),type="o",main="detrended") #just residuals, better for extimating y.t
  plot(diff(gtemp),type="o",main="difference") #better for coercing stationarity
  par(mfrow=c(3,1))
  acf(gtemp,48,main="gtemp")
  acf(resid(fit),48,main="detrended") #removed trend still see seasonal component
  acf(diff(gtemp),48,main="first difference") #looks like noise, implies rw with drift

  #2.4 Differencing Global Temperature
  mean(diff(gtemp))  # .00659 (drift)
  sd(diff(gtemp))/sqrt(length(diff(gtemp))) #.00996 (SE)

#Ex 1.3 Speech Data - Ahh ha
plot(speech)

#Ex 1.4 New York Stock Exchange
  #Daily returns 1984-1991 - Crash in 1987
  #typical of return data, stable mean, volitility clustering
  #use ARCH, GARCH and stochastic volitility models
plot(nyse,ylab="NYSE Returns")

#1.5 EL NINO and FISH
  #Southern Oscillation Index - change in air pressure related to surface temps
  #Recruitment - # of new fish Monthly, 453 months, 1950-198750
  #Periodic behavior in both series, SOI repeat faster than Recruitment
  #Recruitment has 2 frequencies 12 months and 50 months
  #lagged relationship between SOI and Recruitment
par(mfrow=c(2,1))
plot(soi,ylab="",xlab="",main="SOI")
plot(rec,ylab="",xlab="",main="Recruitment")

  #1.25 SOI and Recruitment Correlation Analysis
    #ACFs exhibit periodicities corresponding to the values separated by 12 units
    #Negative correlations are seen at 6 months, characteristic of sinusoidal with period 12 months
    #cross correlation peak at -6 implies SOI leads recruitment by 6 months in opposite directions
  par(mfrow=c(3,1))
  acf(soi,48,main = "SOI")
  acf(rec,48,main="Recruitment")
  ccf(soi,rec,48,main="SOI vs Recruitment",ylab="CCF")
  
  #2.3 Regression with Lagged Variables
    #Likely not linear but assume 6 month lead time R=B.1+B.2*S.t-6+w.t
    # the RSE and DF indicate a strong predictive ability 6 months in advance
  fish=ts.intersect(rec,soiL6=lag(soi,-6),dframe=TRUE) #aligns the lagged series, creates data frame
  summary(lm(rec~soiL6,data=fish,na.action=NULL))

  #2.7 Scaterplot Matricies, SOI and Recruitment
    #autocorrelations (meaningful if linear) in corner and lowess lines to help discover nonlinearities
  lag2.plot(soi,soi,8)
  lag2.plot(soi,rec,8)

#1.6 fMRI Imaging - signal in noise
  #Blood Oxygenation level dependant signal intensity BOLD - activation measure
  #Hand stimulated for 32 sec, stopped for 32 sec, samples every 2 sec (n=128)
  #periodicities strongly in motor cortex, less strongly in thalamus and cerebellum
par(mfrow=c(2,1),mar=c(3,2,1,0)+.5,mgp=c(1.6,.6,0))
ts.plot(fmri1[,2:5],lty=c(1,2,4,5),ylab="BOLD",xlab="",main="Cortex")
ts.plot(fmri1[,6:9],lty=c(1,2,4,5),ylab="BOLD",xlab="",main="Thalamus & Cerebellum")
mtext("Time(1 pt=2 sec"),side = 1, line=2)

#1.7 Earthquakes and Explostions
  #See Homework 1.2 for similar models
par(mfrow=c(2,1))
plot.ts(EQ5, main="Earthquake", xlab="",ylab="")
plot.ts(EQ5, main="Explosion", xlab="",ylab="")

#1.8 While Noise & 1.9 Moving Averages
  #notice no repeating, sinusoidal type behavior
w=rnorm(500,0,1) #500 variates, N(0,1)
v=filter(w, sides=2, rep(1/3,3)) # moving average v=1/3(w.t-1+w.t+w.t+1)
par(mfrow=c(2,1))
plot.ts(w,main="white noise")
plot.ts(v,main="moving average")

#2.10 MOving Average Smoother - Mortality, weekly data
ma5 = filter(cmort,sides = 2,rep(1,5)/5) #monthly avg - shows seasonal component
ma53 = filter(cmort,sides = 2,rep(1,53)/53) #annual avg, - neg trend in mort
plot(cmort,type="p",ylab="mortality")
lines(ma5);lines(ma53)



  #2.2 Pollution, Temperature and Mortality - strong seasonal components
  par(mfcol=c(3,1), mar = c(1,2,1,1))
  plot(cmort,main="Cardiovascular Mortality",xlab="",ylab="")
  plot(tempr,main="Temperature",xlab="",ylab="")
  plot(part,main="Particulates",xlab="",ylab="")
    #linear relationship polutants
    #curvelinear relationship to temperature - mortality at high and low temps
    #4 models fitted - see notes
    #residulas show significant autocorrelation
  pairs(cbind(Mortality=cmort,Temperature=tempr,Particulates=part))
  temp=tempr-mean(tempr) #center temperature
  temp2=temp^2
  trend=time(cmort)
  fit=lm(cmort~trend+temp+temp2+part,na,action=NULL)
  summary(fit)
  summary(aov(fit)) #ANOVA table
  summary(aov(lm(cmort~cbind(trend,temp,temp2,part))))
  num=length(cmort)
  AIC(fit)/num - log(2*pi) #AIC
  AIC(fit,k=log(num))/num - log(2*pi) #BIC
  (AICc = log(sum(resid(fit)^2)/num)+(num+5)/(num-5-2)) #AICc
  acf(fit$resid)

  #2.11 Ploynomial and Periodic Regression Smoothers
  #fitting B.0+B.1t.1+B.2t^2+B.3t^3 and B.0+B.1t.1+B.2t^2+B.3t^3+a.1*cos(2pi*t/52)+a.2*sin(2pi*t/52)
  wk=time(cmort)-mean(time(cmort))
  wk2=wk^2; wk3=wk^3
  cs=cos(2*pi*wk); sn=sin(2*pi*wk)
  reg1=lm(cmort~wk+wk2+wk3,na.action=NULL)
  reg2=lm(cmort~wk+wk2+wk3+cs+sn,na.action=NULL)
  plot(cmort,type="p",ylab="mortality")
  lines(fitted(reg1))
  lines(fitted(reg2))
  
  #similar example given in class
  par(mfcol=c(1,1), mar = c(1,2,1,1))
  fit=lm(gtemp~poly(time(gtemp),3,raw=TRUE),na.action=NULL)
  summary(fit) #small pvalues suggest AT LEAST 3rd order
  plot(resid(fit)) #is this noise?
  plot(gtemp,type="l")
  lines(fitted(fit),col="red")
  acf(resid(fit)) #high at lag one suggests better options
  AIC(fit)/length(gtemp)-log(2*pi)


  #2.12 Kernal Smoothing
  #for this example b=5/52=2-3 week averages and b=104/52 =annual averages
  plot(cmort,type="p",ylab="mortality")
  lines(ksmooth(time(cmort),cmort,"normal",bandwidth=5/52))
  lines(ksmooth(time(cmort),cmort,"normal",bandwidth=2))

  #2.13 Lowess and Nearest Neighor
  #k=n/2 for trend and k=n/100 for seasonal
  #more neighbors = smoother
  par(mfrow=c(2,1))
  plot(cmort,type="p",ylab="mortality",main="nearest neighbor")
  lines(supsmu(time(cmort),cmort,span=.5))
  lines(supsmu(time(cmort),cmort,span=.01))
  plot(cmort,type="p",ylab="mortality",main="nearest neighbor")
  lines(lowess(cmort,f=.02))
  lines(lowess(cmort,f=2/3))
  #much beter than MA, retains higher and longer peaks

  #2.14 Smoothing Splines - knots fit with regression p=3
  par(mfrow=c(1,1))
  plot(cmort,type="p",ylab="mortality")
  lines(smooth.spline(time(cmort),cmort))
  lines(smooth.spline(time(cmort),cmort,spar=1)) trend

#2.15 Smoothing one series as a function of another
par(mfrow=c(2,1),mar=c(3,2,1,0)+.5,mgp=c(1.5,.6,0))
plot(tempr,cmort,main="lowess",xlab="temperaure",ylab="mortality")
lines(lowess(tempr,cmort))
plot(tempr,cmort,main="lowess",xlab="temperaure",ylab="mortality")
lines(smooth.spline(tempr,cmort))


#1.10 Autoregressions
  #x.t = x.t-1-.9x.t-2+w.t
par(mfcol=c(1,1),mar = c(2,4,1,4))
w=rnorm(550,0,1) #Add 50 extra
x= filter(w, filter=c(1,-.9),method="recursive")[-(1:50)]
plot.ts(x,main="autoregression")

#1.11 Random Walk with Drift
  #x.t = delta+x.t-1+w.t = drift + sum of all w up to t
set.seed(154)
w=rnorm(200,0,1)
x=cumsum(w)
wd=w+.2
xd=cumsum(wd)
plot.ts(xd,ylim=c(-5,55),main="random walk")
lines(x)
lines(.2*(1:200),lty="dashed") # line with slope = drift

#1.12 Signal in Noise
  #x.t = 2 cos(2*pi*t/50+.6*pi) + w.t
  #Acos(2piut+phi) - A - amplitude, u - frequency, phi is phase shift
  #larger S:N ratio = easier to detect signal, frequently unobservable in noise
cs= 2*cos(2*pi*1:500/50 + .6*pi)
w= rnorm(500,0,1)
par(mfrow=c(3,1),mar=c(3,2,2,1),cex.main=1.5)
plot.ts(cs,main=expression(2*cos(2*pi*1:500/50)))
plot.ts(cs+w,main=expression(2*cos(2*pi*1:500/50 + .6*pi)+N(0,1)))
plot.ts(cs+5*w,main=expression(2*cos(2*pi*1:500/50 + .6*pi)+N(0,25)))

  #2.8 Using Regression to Discover a Signal in Noise
    #known u(frequency)
  par(mfcol=c(1,1),mar = c(2,4,1,4))
  set.seed(1000)
  x= 2*cos(2*pi*1:500/50 + .6*pi) + rnorm(500,0,5)
  z1=cos(2*pi*1:500/50)
  z2=sin(2*pi*1:500/50)
  summary(fit<-lm(x~0+z1+z2)) # 0 excludes the intercept
  #model is -.71*cos(2pi*t/50)-2.55*sin(2pi*t/50)
  plot.ts(x,lty="dashed")
  lines(fitted(fit),lwd=2)

  #2.9 Using Periodogram to Discover Signal in Noise - unkown frequency
  I=abs(fft(x))^2/500 #the periodogram
  P=(4/500)*I[1:250] #scaled periodgram
  f=0:249/500 #frequencies
  plot(f,P,type="l",xlab="Frequency",ylab="Scaled Periodgram") # discovers u=.02


#1.27 ACF and Soil Temperatures - autocorrelation of 2 d process
par(mfcol=c(1,1),mar = c(2,4,1,4))
fs=abs(fft(soiltemp-mean(soiltemp)))^2/(64*36) #fast fouurier transformation
cs=Re(fft(fs,inverse=TRUE)/sqrt(64*36))#ACovF
rs=cs/cs[1,1] #ACF
rs2=cbind(rs[1:41,21:2],rs[1:41,1:21])
rs3=rbind(rs2[41:2,],rs2)
par(mar=c(1,2.5,0,0)+.1)
persp(-40:40,-20:20,rs3,phi=30,theta=30,expand=30,scale="FALSE"
      ,ticktype="detailed",xlab="row lags",ylab="col lags",zlab="ACF")

#2.6 Paleoclimatic Glacial Varves - log transformation reduces variability and can induce stationarity
par(mfrow=c(2,1))
plot(varve,main="varve",ylab="")
plot(log(varve),main="log(varve)",ylab="") #needs more

#examples given in class
plot(diff(log(varve)))
library(MASS)
time=time(varve)[2:634]
min=min(diff(varve))
boxcox(diff(varve)-min-time)
















