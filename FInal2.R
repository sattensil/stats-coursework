library(readr)
ins <- read_csv("C:/Users/Scarlett/Google Drive/201501_CSUEB/201704_Spring_Regression/insurance.csv")

#data descriptions
ins$sex = as.factor(ins$sex)
ins$group = as.factor(ins$group)
ins$region = as.factor(ins$region)
summary(ins)

hist(ins$expenses, main = "",xlab="Expenses")
expensesBox=boxplot(ins$expenses, ylab="Expenses")
length(expensesBox$out)/length(ins$expenses)
min(expensesBox$out)
sd(ins$expenses)

hist(ins$age, main = "",xlab="Age",breaks=(64-18)/5)
sd(ins$age)
sd(ins$age)/(max(ins$age)-min(ins$age))

hist(ins$bmi, main = "",xlab="BMI",breaks=20)
bmiBox=boxplot(ins$bmi)
min(bmiBox$out)
sd(ins$bmi)
sd(ins$bmi)/(max(ins$bmi)-min(ins$bmi))

hist(ins$children, main = "",xlab="Children",breaks=5)
min(childrenBox$out)
sd(ins$children)
sd(ins$children)/(max(ins$children)-min(ins$children))

length(subset(ins$group,ins$group=='yes'))/length(ins$group)
plot(ins$region, xlab="Region")

#data analysis
cor(ins[,c(1,3,4,7)])
pairs(ins)
install.packages("psych")
library(psych)
pairs.panels(ins[,c(1,3,4,7)])
library(ggplot2)
qplot(bmi,expenses, colour = group, shape = group, data = ins, ylab="Expenses", xlab="BMI")
ins$group=ifelse(ins$group=='yes'& ins$bmi>30,'group High BMI',
                 ifelse(ins$group=='yes','group Low BMI','Nongroup'))
qplot(age, expenses, colour = group, shape = group, data = ins)


#a - untransformed, all variables, no interactions
a=lm(expenses~age+sex+group+region+children+bmi, data=ins)
plot(a)
shapiro.test(a$residuals)
boxcox(a)

library(MASS)
aa <- stepAIC(a, direction="both")
aaa=aa$anova # display results
aaa
plot(aaa$AIC,xlab="Step",ylab="AIC",type="l")

#determine transformation
boxcox(a)$x[which(boxcox(a)$y==max(boxcox(a)$y))]# 0.1010101
boxcox(lm(expenses ~ age, data = ins))$x[which(boxcox(lm(expenses ~ age, data = ins))$y
                      ==max(boxcox(lm(expenses ~ age, data = ins))$y))]#-0.1010101
boxcox(lm(expenses ~ bmi, data = ins))$x[which(boxcox(lm(expenses ~ bmi, data = ins))$y
                      ==max(boxcox(lm(expenses ~ bmi, data = ins))$y))]#0.06060606
boxcox(lm(expenses ~ children, data = ins))$x[which(boxcox(lm(expenses ~ children, data = ins))$y
                      ==max(boxcox(lm(expenses ~ children, data = ins))$y))]#0.02020202


#transform
ins$logexpenses = log(ins$expenses, base=exp(1))
ins$age2= ins$age*ins$age

tr = lm(logexpenses ~ age+sex+group+region+children+bmi, data = ins)
summary(tr)
plot(tr)

shapiro.test(tr$residuals)

tr2 = lm(logexpenses ~ age+age2+sex+group+region+children+bmi, data = ins)
summary(tr2)
plot(tr2)




#for visuals

a2=lm(logexpenses~age, data=ins)
a3=lm(logexpenses~sex, data=ins)
a4=lm(logexpenses~group, data=ins)
a5=lm(logexpenses~children, data=ins)
a6=lm(logexpenses~region, data=ins)
a7=lm(logexpenses~bmi, data=ins)


y=c(AIC(a2),AIC(a3),AIC(a4),AIC(a5),AIC(a6),AIC(a7))
names(y)=c('age','sex','group','children','region','bmi')
library(lattice)
barchart(y, xlab='AIC')

a=lm(expenses~group, data=ins)
b=lm(expenses~group+age+age2, data=ins)
c=lm(expenses~group+age+age2+bmi, data=ins)
d=lm(expenses~group+age+age2+bmi+children, data=ins)
e=lm(expenses~group+age+age2+bmi+children+region, data=ins)
f=lm(expenses~group+age+age2+bmi+children+region+sex, data=ins)

aa=lm(logexpenses~group, data=ins)
bb=lm(logexpenses~group+age+age2, data=ins)
cc=lm(logexpenses~group+age+age2+bmi, data=ins)
dd=lm(logexpenses~group+age+age2+bmi+children, data=ins)
ee=lm(logexpenses~group+age+age2+bmi+children+region, data=ins)
ff=lm(logexpenses~group+age+age2+bmi+children+region+sex, data=ins)


y=c(AIC(a),AIC(b),AIC(c),AIC(d),AIC(e),AIC(f))
y2=c(BIC(a),BIC(b),BIC(c),BIC(d),BIC(e),BIC(f))
y3=c(summary(a)$r.squared,summary(b)$r.squared
     ,summary(c)$r.squared,summary(d)$r.squared
     ,summary(e)$r.squared,summary(f)$r.squared)

z=c(AIC(aa),AIC(bb),AIC(cc),AIC(dd),AIC(ee),AIC(ff))
z2=c(BIC(aa),BIC(bb),BIC(cc),BIC(dd),BIC(ee),BIC(ff))
z3=c(summary(aa)$r.squared,summary(bb)$r.squared
     ,summary(cc)$r.squared,summary(dd)$r.squared
     ,summary(ee)$r.squared,summary(ff)$r.squared)


plot(z,type='l',ylab="AIC",xlab='Number of Predictors',ylim=c(1500,30000))
lines(y,col='red')

plot(z,type='l',ylab="AIC",xlab='Number of Predictors',ylim=c(1500,3000))


plot(z3,type='l',ylab='Adj. R Squared',xlab='Number of Predictors',ylim=c(.5,1))
lines(y3,col="red")




