#76
x=floor(runif(50, min = 1, max = 1000))
x
#94
a=c(.47,.58,.67,.7,.77,.79,.81,.82,.84,.86,.91,.95,.98,1.01,1.04)
qqnorm(a)

#44
a=c(1660,1820,1590,1440,1730,1680,1750,1720,1900,1570,1700,1900,1800,1770,2010,1580,1620,1690)
qqnorm(a)

#Scarlett Townsend 
#Extra Credit Assignment
#6-5
a=c(152,157,179,182,176,149)
b=c(384,369,354,375,366,423)
mean(a)
mean(b)
sd(a)
sd(b)
t.test(a,b,paired=FALSE)
t.test(a,b,paired=FALSE,alternative="less")
#6-8
a=c(0,0,0,13,15,19,23,23,24,25,27,30,30,32,33,34,35,35,38,39,40,40,41,42,44,45,50,55,55,62)
length(a)
b=c(22,29,29,32,36,36,38,38,39,40,40,40,41,41,42,43,43,43,45,45,46,46,46,52,59)
length(b)
mean(a)
mean(b)
sd(a)
sd(b)
t.test(a,b,paired=FALSE,alternative="less")
boxplot(a)
boxplot(b)
#6-11
a=c(61.48,64.47,45.5,59.7,58.81,75.86,71.57,38.06,30.51,39.7,29.78,66.89,63.93)
length(a)
b=c(13.99,18.26,11.28,10.02,21,17.36,28.2,7.3,12.8,9.41,12.63,16.83,22.74)
length(b)
mean(a)
mean(b)
sd(a)
sd(b)
t.test(a,b,paired=FALSE,var.equal=FALSE,alternative="less")
t.test(a,b,paired=FALSE,var.equal=FALSE)
x=cbind(a,b)
boxplot(x)
#6-12
t.test(a,b,paired=TRUE,var.equal=FALSE)
t.test(a,b,paired=TRUE,var.equal=FALSE,alternative="less")
#7-7
qchisq(.995, 149)
qchisq(.005, 149)

((149*9.537^2)/qchisq(.995, 149))^.5
((149*9.537^2)/qchisq(.005, 149))^.5

(149*9.537^2)/90

qchisq(.95, 149)

(149*9.537^2)/90 >= qchisq(.95, 149)

#7-9

(80*1.771^2)/4

qchisq(.05,80)

(80*1.771^2)/4 <= qchisq(.05, 80)

qchisq(.975, 80)
qchisq(.025, 80)
((80*1.771^2)/qchisq(.975, 80))^.5
((80*1.771^2)/qchisq(.025, 80))^.5

#7-15
#old
qchisq(.975,60)
qchisq(.025,60)
((60*.231^2)/qchisq(.975,60))^.5
((60*.231^2)/qchisq(.025,60))^.5
#new
((60*.162^2)/qchisq(.975,60))^.5
((60*.162^2)/qchisq(.025,60))^.5

.231^2/.162^2

qf(.95, 60,59)

.231^2/.162^2 >= qf(.95, 60,59)

#7-16
#computer
((90*53.77^2)/chisq(.975,90))^.5
((90*53.77^2)/chisq(.025,90))^.5
#conventional
((90*36.94^2)/chisq(.975,90))^.5
((90*36.94^2)/chisq(.025,90))^.5

.231^2/.162^2

qf(.95, 60,59)

.231^2/.162^2 >= qf(.95, 60,59)