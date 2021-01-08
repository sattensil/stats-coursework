library(readr)
ins <- read_csv("C:/Users/Scarlett/Google Drive/201501_CSUEB/201704_Spring_Regression/insurance.csv")

ins$sex.smoker=ifelse(ins$sex=='female'& ins$smoker=='yes', 'Female Smoker',
                ifelse(ins$sex=='female'& ins$smoker=='no', 'Female Nonsmoker',
                       ifelse(ins$sex=='male'& ins$smoker=='no', 'Male Nonsmoker',
                              'Male Smoker')) )
ins$bmi2=ifelse(ins$bmi>30,'>30','<=30')

ins$group=ifelse(ins$smoker=='yes'& ins$bmi>30,'Smoker High BMI',
                ifelse(ins$smoker=='yes','Smoker Low BMI','Nonsmoker'))
                       
boxplot(ins$expenses, main="Expenses")

View(ins)
cor(ins[,c(1,3,4,7)])
pairs(ins[,c(1,3,4,7)])

library(ggplot2)
qplot(age, expenses, colour = group, shape = group, data = ins)
qplot(children, age, colour = group, shape = region, data = ins)
qplot(bmi,expenses, colour = smoker, shape = smoker, data = ins, ylab="Expenses", xlab="BMI")

x=subset(ins,group=='Nonsmoker')
qplot(age, expenses, colour = region, shape = group, data = x)
qplot(bmi,expenses, colour = region, shape = smoker, data = x)

ggplot(ins, aes(x = region, y = age,colour = group)) +
  geom_boxplot()

interactions=lm(expenses~factor(sex)*factor(region)*factor(smoker)*age*children*bmi, data=ins)
summary(interactions)

library(MASS)
stepinteractions <- stepAIC(interactions, direction="both")
stepinteractions$anova # display results

shapiro.test(suggested$residuals)
boxcox


additive=lm(expenses~factor(sex)+factor(region)+factor(smoker)+age+children+bmi, data=ins)
summary(additive)
stepadditive <- stepAIC(additive, direction="both")
stepadditive$anova # display results

log_additive=lm(log(expenses,base=exp(1))^4~factor(group)+age, data=ins)
summary(log_additive)
boxcox(log_additive)$x[which(boxcox(log_additive)$y==max(boxcox(log_additive)$y))]#2


log_additive2=lm((log(expenses,base=exp(1)))^2~factor(group)+age+children+bmi, data=ins)
summary(log_additive2)
boxcox(log_additive2)$x[which(boxcox(log_additive2)$y==max(boxcox(log_additive2)$y))]#2


stepadditive <- stepAIC(log_additive2, direction="both")
stepadditive$anova # display results

log_additive3=lm(log(expenses, base = exp(1))^2 ~ factor(sex) + factor(region) + 
  factor(smoker) + age + children + bmi,data=ins)

shapiro.test(log_additive3$residuals)



log_sex=lm(log(expenses,base=exp(1))~factor(sex), data=ins)
log_region=lm(log(expenses,base=exp(1))~factor(region), data=ins)
log_smoker=lm(log(expenses,base=exp(1))~factor(smoker), data=ins)
log_age=lm(log(expenses,base=exp(1))~age, data=ins)
log_bmi=lm(log(expenses,base=exp(1))~bmi, data=ins)
log_children=lm(log(expenses,base=exp(1))~children, data=ins)

sex=lm(expenses~factor(sex), data=ins)
region=lm(expenses~factor(region), data=ins)
smoker=lm(expenses~factor(smoker), data=ins)
age=lm(expenses~age, data=ins)
bmi=lm(expenses~bmi, data=ins)
children=lm(expenses~children, data=ins)

boxcox(sex)$x[which(boxcox(sex)$y==max(boxcox(sex)$y))]#0.06060606
boxcox(region)$x[which(boxcox(region)$y==max(boxcox(region)$y))]#0.06060606
boxcox(smoker)$x[which(boxcox(smoker)$y==max(boxcox(smoker)$y))]#0.3434343
boxcox(age)$x[which(boxcox(age)$y==max(boxcox(age)$y))]#  -0.1010101
boxcox(bmi)$x[which(boxcox(bmi)$y==max(boxcox(bmi)$y))]#0.06060606
boxcox(children)$x[which(boxcox(children)$y==max(boxcox(children)$y))]#0.02020202

boxcox(log_sex)$x[which(boxcox(log_sex)$y==max(boxcox(log_sex)$y))]#1.313131
boxcox(log_region)$x[which(boxcox(log_region)$y==max(boxcox(log_region)$y))]#1.313131
boxcox(log_smoker)$x[which(boxcox(log_smoker)$y==max(boxcox(log_smoker)$y))]#2
boxcox(log_age)$x[which(boxcox(log_age)$y==max(boxcox(log_age)$y))]#  -0.06060606
boxcox(log_bmi)$x[which(boxcox(log_bmi)$y==max(boxcox(log_bmi)$y))]#1.393939
boxcox(log_children)$x[which(boxcox(log_children)$y==max(boxcox(log_children)$y))]#1.111111


shapiro.test(sex$residuals)#nonnormal
shapiro.test(region$residuals)#nonnormal
shapiro.test(smoker$residuals)#nonnormal
shapiro.test(age$residuals)#nonnormal
shapiro.test(bmi$residuals)#nonnormal
shapiro.test(children$residuals)#nonnormal


lm1=lm(expenses~factor(smoker)+age+children+bmi, data=ins)
summary(lm1)

#factors
interaction.plot(ins$sex,ins$smoker,ins$expenses)
interaction.plot(ins$sex,ins$region,ins$expenses)#interaction
interaction.plot(ins$region,ins$smoker,ins$expenses)

interaction.plot(ins$age,ins$group,ins$expenses)
interaction.plot(ins$sex,ins$group,ins$expenses)
interaction.plot(ins$region,ins$group,ins$expenses)
interaction.plot(ins$children,ins$group,ins$expenses)




log_interactions=lm(expenses~factor(sex)*factor(region)*factor(smoker)*age*log(children+1,base=exp(1))*bmi, data=ins)

library(MASS)
steplog_interactions <- stepAIC(log_interactions, direction="both")
steplog_interactions$anova # display results
                                                                                                                                                                                                        1, base = exp(1)) + factor(sex):factor(smoker):log(children + 
                                                                                                                                                                                                                                                                                                   1, base = exp(1)):bmi + factor(sex):factor(region):factor(smoker):age:log(children + 
                                                                                                                                                                                                                                                                                                                                                                               1, base = exp(1)),data=ins)
shapiro.test(suggested2$residuals)

nonsmoker=subset(ins,group=='Nonsmoker')
nonsmoker$y=-nonsmoker$expenses^(-3)

nonsmoker$x=log(-nonsmoker$y,base=exp(1))

nonsmoker$z=nonsmoker$x^2
plot(lm(x~age,data=nonsmoker))


ins$age2=ins$age^2
log_interactions=lm(log(expenses,base=exp(1))
                    ~factor(region)*factor(group)
                    *age2*bmi*children, data=ins)

library(MASS)
steplog_interactions <- stepAIC(log_interactions, direction="both")
steplog_interactions$anova # display results


boxplot(ins$expenses~ins$group)