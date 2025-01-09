# One way ANOVA
# salary vs. sex_Rank

salary1<-Salary_sex$salary

rank_sex<-factor(Salary_sex$sex.Rank)

# first quick look of data
boxplot(salary1~rank_sex)
# conduct one-way anova
result<-aov(salary1~rank_sex)
summary(result)

rank1<-factor(Salary_sex$Rank)
boxplot(salary1~rank1,
  xlab = "Rank",
  ylab = "Salary",
  main = "Median Salary In Different Ranks")

##### diagnostics
# extract residuals, fitted values
rs<-rstandard(result)
fits<-fitted.values(result)
# check the normality of residuals
qqnorm(rs)
qqline(rs,col=2)
shapiro.test(rs)

# check the equal variance assumption
# you must load library 'car' first
library(car)
plot(fits,rs,main="residuals vs. fitted values")
leveneTest(salary1~rank_sex)

# check for independence among observations
plot(rs,type="l",main="run order plot")
# no time/order dependent pattern is shown




sal<-log(salary1)
# redo the whole procedure:
result2<-aov(sal~rank_sex)
rs2<-rstandard(result2)
fits2<-fitted.values(result2)
qqnorm(rs2)
qqline(rs2,col=2)
shapiro.test(rs2)
plot(fits2,rs2,main="residuals vs. fitted values")
leveneTest(sal~rank_sex)
plot(rs2,type="l",main="run order plot")

a = TukeyHSD(result)
table(a)
boxplot(sal)
boxplot(salary1)



salary2<-Prof$salary

rank_sex<-factor(Prof$sex.Rank)
sal2<-log(salary2)
# first quick look of data
boxplot(sal2~rank_sex)
# conduct one-way anova
result<-aov(sal2~rank_sex)
summary(result)


salary3<-AsstProf$salary

rank_sex<-factor(AsstProf$sex.Rank)
sal3<-log(salary3)
# first quick look of data
boxplot(sal3~rank_sex)
# conduct one-way anova
result<-aov(sal3~rank_sex)
summary(result)


salary4<-AssocProf$salary

rank_sex<-factor(AssocProf$sex.Rank)
sal4<-log(salary4)
# first quick look of data
boxplot(sal4~rank_sex)
# conduct one-way anova
result<-aov(sal4~rank_sex)
summary(result)

