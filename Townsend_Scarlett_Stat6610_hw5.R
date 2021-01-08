library(astsa) 

plot(jj, type="o", ylab="Quarterly 
     Earnings per Share")

plot(log(jj), type="o", ylab="Quarterly 
     Earnings per Share")

plot(decompose(jj))

acf(jj)

pacf(jj)