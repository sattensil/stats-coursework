colnames(MOA)
moa <- subset( MOA, select = -c(2,3,6,7,9,10,11) )
colnames(moa)=c("Race","HDI","LE","ME")

#a. Compare the HD Index for the various races 
require ("ggplot2")
ggplot(moa, aes(x=Race, y=HDI)) + geom_boxplot()

#b. Develop an additive regression model with your 2 predictors (race, and income) for predicting HD Index. 
  #Obtain the regression coefficients and interpret them. 

lm1 <-lm(HDI~(ME + factor(Race),data = moa)
summary(lm1)
shapiro.test(lm1$residuals)

#c. Next run a full model with all possible interaction terms (again with just two predictors), 
  #provide the regression coefficients along with any relevant interpretations. 
lm2 <-lm(HDI~ME * factor(Race),data = moa)
summary(lm2)

#d. Create visual displays for both the additive and interaction models in parts (b) and (c) 
  #with the data points and the estimated regression equations. 
ggplot(moa,aes(y = HDI, x =ME,colour=Race,shape=Race)) +
  geom_point() + geom_smooth(method="lm", fill=NA)

library(visreg)

visreg(lm1, "ME", by="Race", overlay=TRUE, partial=FALSE)
visreg(lm2, "ME", by="Race", overlay=TRUE, partial=FALSE)

#e. Now include life expectancy as a predictor and run an additive model. 
  #Check for model assumptions using residual plots and for normality and 
  #equal variances using formal tests. Provide your thoughts along with the outputs.
lm3 <-lm(HDI~ME + LE+ factor(Race),data = moa)
lm4 <-lm(HDI~ME * LE * factor(Race),data = moa)
summary(lm3)
plot(lm3)
shapiro.test(lm3$residuals)


lm4 <-lm(HDI~ME*LE*factor(Race),data = moa)

#f. Check for an outliers present in the data. Use any appropriate plot to identify 
    #TWO points with the larges influence. 

#g. Finally use the AIC to justify the choice of model with our 3 predictors. 
  #Provide edited results.
AIC(lm1) 
AIC(lm2) 
AIC(lm3) 


anova(lm2,lm3)
1-pf(7.094,2,83)

moa$levene <- ifelse(moa$HDI<=5, "L","U")
leveneTest(moa$HDI~moa$levene)

moa[c(54,27),]
lm3$fitted.values[c(54,27)]
