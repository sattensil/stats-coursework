setwd("C:/Users/Scarlett/Google Drive/CSUEB/Math Stats/Book Data/Chapter 10")
#Scarlett Townsend
#STAT 6502 HW #1

#10.6
bw=read.table(file = "beeswax.txt",sep = ",",header=TRUE)
  #a
  plot(ecdf(bw$Hydrocarbon),main = "ecdf Hydrocarbon")
  quantile(ecdf(bw$Hydrocarbon),c(.9,.75,.5,.25,.1))
  qnorm(c(.9,.75,.5,.25,.1), mean = mean(bw$Hydrocarbon), sd = sd(bw$Hydrocarbon))
  
  #book example
  quantile(bw$MeltingPoint,c(.9,.12)) #??
  plot(ecdf(bw$MeltingPoint),main = "ecdf Melting Point",xlim=c(62,68))
  lines(ecdf(bw$MeltingPoint+rep(.85,59)),col="red")
  lines(ecdf(bw$MeltingPoint+rep(2.22,59)),col="blue")


  #10.6
  m=matrix(data = rep(c(0,.01,.03,.05),59), nrow = 59, ncol = 4, byrow = TRUE)
  dillution=bw$Hydrocarbon*(1-m)+m*85
  plot(ecdf(dillution[,1]),main = "ecdf Hydrocarbon",xlim=c(13,20))
  lines(ecdf(dillution[,2]),col="red")
  lines(ecdf(dillution[,3]),col="blue")
  lines(ecdf(dillution[,4]),col="green")
  summary(dillution)
# 3% and 5% dillutions would detectable.
  
#10.29 c)
  x=rbinom(26,1,5/26)
  y=numeric(1000)
  for (i in 1:1000) (y[i]=sum(sample(x,26,replace=TRUE)))
  sum(ifelse(y>=10,1,0))
  hist(y)