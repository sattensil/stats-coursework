#Week 4, Activity 2
# Try out using googleVis from within R

library(googleVis)

data(Fruits)

M1 <- gvisMotionChart(Fruits, idvar="Fruit", timevar="Year")

plot(M1)
#########################################################################
#Week 4, Activity 1
library(wordcloud)
library(tm)

# First simple example
# from help(wordcloud)

wordcloud(c(letters, LETTERS, 0:9), seq(1, 1000, len = 62))

# So to make a workcloud in R you need a list of word and the list of 
# coresponding frequencies.

# Second Example.
# from help(wordcloud)

wordcloud(
  "Many years ago the great British explorer George Mallory, who 
  was to die on Mount Everest, was asked why did he want to climb 
  it. He said, \"Because it is there.\"
  
  Well, space is there, and we're going to climb it, and the 
  moon and the planets are there, and new hopes for knowledge 
  and peace are there. And, therefore, as we set sail we ask 
  God's blessing on the most hazardous and dangerous and greatest 
  adventure on which man has ever embarked.",
  ,random.order=FALSE)


# Third Example
# Download Moby Dick from https://www.gutenberg.org/
# Save it to a directory, for me E:\tm\

moby <- Corpus(DirSource("C:\\Users\\Scarlett\\Google Drive\\201501_CSUEB\\201601_Winter_DataVisualization\\moby", 
               encoding = "UTF-8"))

inspect(moby)

moby <- tm_map(moby, stripWhitespace)
moby <- tm_map(moby, removeNumbers)
moby <- tm_map(moby, removePunctuation)
inspect(moby)

moby <- tm_map(moby, removeWords, stopwords('english'))

moby <- tm_map(moby, removeWords, c("and","the","our","that",
                                    "for","are","also","more",
                                    "has","must","have","should",
                                    "this","with"))
inspect(moby)

moby <- tm_map(moby, tolower)
moby <- tm_map(moby, PlainTextDocument)

inspect(moby)

tdm <- TermDocumentMatrix(moby)

m <- as.matrix(tdm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)

wordcloud(d$word,d$freq,min.freq=2,max.words=100)

# Fourth Example

data(crude)
inspect(crude)

crude <- tm_map(crude, removePunctuation)
inspect(crude)

moby <- tm_map(moby, removeWords, stopwords('english'))

crude <- tm_map(crude, removeWords, stopwords('english'))
inspect(crude)

tdm <- TermDocumentMatrix(crude)

m <- as.matrix(tdm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)

wordcloud(d$word,d$freq)

# Fifth Example
# http://www.r-bloggers.com/word-cloud-in-r/

library(XML)
library(tm)
library(wordcloud)
library(RColorBrewer)
u = "http://cran.r-project.org/web/packages/available_packages_by_date.html"
t = readHTMLTable(u)[[1]]
ap.corpus <- Corpus(DataframeSource(data.frame(as.character(t[,3]))))

inspect(ap.corpus)

ap.corpus <- tm_map(ap.corpus, removePunctuation)

ap.corpus <- tm_map(ap.corpus, tolower)
ap.corpus <- tm_map(ap.corpus, PlainTextDocument)

ap.corpus <- tm_map(ap.corpus, function(x) removeWords(x, stopwords("english")))

ap.tdm <- TermDocumentMatrix(ap.corpus)

ap.m <- as.matrix(ap.tdm)
ap.v <- sort(rowSums(ap.m),decreasing=TRUE)
ap.d <- data.frame(word = names(ap.v),freq=ap.v)

table(ap.d$freq)

pal2 <- brewer.pal(8,"Dark2")

wordcloud(ap.d$word,ap.d$freq, scale=c(8,.2),min.freq=3,
          max.words=Inf, random.order=FALSE, rot.per=.15, colors=pal2)
#########################################################################

yellow <- Corpus(DirSource("C:\\Users\\Scarlett\\Google Drive\\201501_CSUEB\\201601_Winter_DataVisualization\\yellow", 
                           encoding = "UTF-8"))

inspect(yellow)

yellow <- tm_map(yellow, stripWhitespace)
yellow <- tm_map(yellow, removeNumbers)
yellow <- tm_map(yellow, removePunctuation)
inspect(yellow)

yellow <- tm_map(yellow, removeWords, stopwords('english'))

yellow <- tm_map(yellow, removeWords, c("and","the","our","that",
                                        "for","are","also","more",
                                        "has","must","have","should",
                                        "this","with"))
inspect(yellow)

yellow <- tm_map(yellow, tolower)
yellow <- tm_map(yellow, PlainTextDocument)

inspect(yellow)

tdm <- TermDocumentMatrix(yellow)

m <- as.matrix(tdm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)

wordcloud(d$word,d$freq,min.freq=2,max.words=100)
#########################################################################
#Week 4, Activity 6
# Playing with R
# Plotting Maps with R

library(maptools)
library(RColorBrewer)
library(classInt)

## set the working directory.
setwd("C:\\Users\\Scarlett\\Downloads\\bayarea_zipcodes")

## load the shapefile
zip<- readShapePoly("bayarea_zipcodes.shp")

#add the median household incomes for each zipcode to the .shp file 
med.income = c(55995, 54448, 50520, 43846, 50537, 67705, 45142, 36518, NA, 65938, 50500, 61022, 65959, 17188, 53881, 66970, 35699, 76194, 63777, 63838, 66010, 48523, 70758, 41002, 60082, 48672, 61429, 60402, 75707, 58333, 60769, 60375, 76627, 68515, 64485, 60971, 60833, 54732, 60804, 33962, 57601, 43649, 59889, NA, 61494, 67824, 64429, 82528, 101555, 96658, 50300, 41573, 75747, 53750, 56905, 85479, 77455, 64389, 91283, 119832, 103791, 100590, 85109, 88184, 57153, 34951, 51418, 38613, 43640, 19750, 139997, 39290, NA, 76808, 98525, 106492, 68112, 68853, 77952, 34398, 75026, 33556, NA, 109771, 142459, 80959, 21124, 49066, 95588, 55321, 20034, 57976, 40990, 73571, 84710, 43444, 32273, 56569, 54174, 105393, 51896, 31542, 33152, 54879, 88976, 14609, 61609, 61776, 22351, 31131, 47288, NA, 63983, 60733, 29181, 75727, 61362, 53795, 76044, 34755, 66627, 37146, 92644, 87855, 95313, 50888, 55000, 57629, 54342, 77122, 44723, 64534, 65658, 60711, 57214, 54594, 48523, 90107, 69014, 49452, 72288, 56973, 81923, 61289, 71863, 61939, 0, 82735, 68067, 82188, 70026, 101977, 55112, 84442, 82777, 82796, 92989, 67152, 68121, 69350, 104958, 49279, 80973, 89016, 96677, 89572, 64256, 84565, 16250, 64839, 200001, 82072, 58304, 66807, 97758, 68721, 77539, 41313, NA, 82314, 164479, 69087, 145425, NA, 71056, 128853, 84856)
zip$INCOME = med.income

#select color palette and the number colors (levels of income) to represent on the map
colors <- brewer.pal(9, "YlOrRd")

#set breaks for the 9 colors 
brks<-classIntervals(zip$INCOME, n=9, style="quantile")
brks<- brks$brks

#plot the map
plot(zip, col=colors[findInterval(zip$INCOME, brks,all.inside=TRUE)], axes=F)

#add a title
title(paste ("SF Bay Area Median Household Income"))

#add a legend
legend(x=6298809, y=2350000, legend=leglabs(round(brks)), fill=colors, bty="n",x.intersp = .5, y.intersp = .5)
#########################################################################
## set the working directory.
setwd("C:\\Users\\Scarlett\\Downloads\\bayarea_general")

## load the shapefile
general<- readShapePoly("bayarea_general.shp")

#select color palette and the number colors (levels of income) to represent on the map
colors <- brewer.pal(9, "YlOrRd")

#set breaks for the 9 colors 
brks<-classIntervals(row(general), n=9, style="quantile")
brks<- brks$brks

#plot the map
plot(general, col=colors[findInterval(row(general), brks,all.inside=TRUE)], axes=F)

#add a title
title(paste ("Bay Area General"))
#########################################################################

# ggplot2 examples
library(ggplot2) 

# create factors with value labels 
mtcars$gear <- factor(mtcars$gear,levels=c(3,4,5),
                      labels=c("3gears","4gears","5gears")) 
mtcars$am <- factor(mtcars$am,levels=c(0,1),
                    labels=c("Automatic","Manual")) 
mtcars$cyl <- factor(mtcars$cyl,levels=c(4,6,8),
                     labels=c("4cyl","6cyl","8cyl")) 


# Kernel density plots for mpg
# grouped by number of gears 
# (indicated by color)
qplot(mpg, data=mtcars, geom="density", fill=gear, alpha=I(.5), 
      main="Distribution of Gas Milage", xlab="Miles Per Gallon", 
      ylab="Density")


# Scatterplot of mpg vs. hp for each 
# combination of gears and cylinders
# in each facet, transmition type is 
# represented by shape and color
qplot(hp, mpg, data=mtcars, shape=am, color=am, 
      facets=gear~cyl, size=I(3),
      xlab="Horsepower", ylab="Miles per 
      Gallon") 

# Separate smoothers of mpg on weight for each number of cylinders
qplot(wt, mpg, data=mtcars, geom=c("point", 
                                   "smooth"), color=cyl, 
      main="Smoothers of MPG on Weight", 
      xlab="Weight", ylab="Miles per Gallon")

# Boxplots of mpg by number of gears 
# observations (points) are overlayed and jittered
qplot(gear, mpg, data=mtcars, geom=c("boxplot", "jitter"), 
      fill=gear, main="Mileage by Gear Number",
      xlab="", ylab="Miles per Gallon")

############################################################################
# Set a graphical parameter using par()

par()              # view current settings
opar <- par()      # make a copy of current settings
par(col.lab="red") # red x and y labels 
hist(mtcars$mpg)   # create a plot with these new settings 
par(opar)          # restore original settings

# Set a graphical parameter within the plotting function 
hist(mtcars$mpg, col.lab="red")

# Type family examples - creating new mappings 
plot(1:10,1:10,type="n")
windowsFonts(
  A=windowsFont("Arial Black"),
  B=windowsFont("Bookman Old Style"),
  C=windowsFont("Comic Sans MS"),
  D=windowsFont("Symbol")
)
text(3,3,"Hello World Default")
text(4,4,family="A","Hello World from Arial Black")
text(5,5,family="B","Hello World from Bookman Old Style")
text(6,6,family="C","Hello World from Comic Sans MS")
text(7,7,family="D", "Hello World from Symbol")

# Specify axis options within plot() 
plot(x, y, main="title", sub="subtitle",
     xlab="X-axis label", ylab="y-axix label",
     xlim=c(xmin, xmax), ylim=c(ymin, ymax))

title(main="main title", sub="sub-title", 
      xlab="x-axis label", ylab="y-axis label")

# Add a red title and a blue subtitle. Make x and y 
# labels 25% smaller than the default and green. 
title(main="My Title", col.main="red", 
      sub="My Sub-title", col.sub="blue", 
      xlab="My X label", ylab="My Y label",
      col.lab="green", cex.lab=0.75)

text(location, "text to place", pos)
mtext("text to place", side, line=n)

# Example of labeling points
attach(mtcars)
plot(wt, mpg, main="Milage vs. Car Weight", 
     xlab="Weight", ylab="Mileage", pch=18, col="blue")
text(wt, mpg, row.names(mtcars), cex=0.6, pos=4, col="red")

axis(side, at=, labels=, pos=, lty=, col=, las=, tck=)

# A Silly Axis Example

# specify the data 
x <- c(1:10); y <- x; z <- 10/x

# create extra margin room on the right for an axis 
par(mar=c(5, 4, 4, 8) + 0.1)

# plot x vs. y 
plot(x, y,type="b", pch=21, col="red", 
     yaxt="n", lty=3, xlab="", ylab="")

# add x vs. 1/x 
lines(x, z, type="b", pch=22, col="blue", lty=2)

# draw an axis on the left 
axis(2, at=x,labels=x, col.axis="red", las=2)

# draw an axis on the right, with smaller text and ticks 
axis(4, at=z,labels=round(z,digits=2),
     col.axis="blue", las=2, cex.axis=0.7, tck=-.01)

# add a title for the right axis 
mtext("y=1/x", side=4, line=3, cex.lab=1,las=2, col="blue")

# add a main title and bottom and left axis labels 
title("An Example of Creative Axes", xlab="X values",
      ylab="Y=X")

# Add minor tick marks
library(Hmisc)
n=10
minor.tick(nx=n, ny=n, tick.ratio=n)
yvalues=c(1,2,3)
xvalues=c(3,2,1)
abline(h=yvalues, v=xvalues)

# add solid horizontal lines at y=1,5,7 
abline(h=c(1,5,7))
# add dashed blue verical lines at x = 1,3,5,7,9
abline(v=seq(1,10,2),lty=2,col="blue")

legend(location, title, legend, ...)

# Legend Example
attach(mtcars)
boxplot(mpg~cyl, main="Milage by Car Weight",
        yaxt="n", xlab="Milage", horizontal=TRUE,
        col=terrain.colors(3))
legend("topright", inset=.05, title="Number of Cylinders",
       c("4","6","8"), fill=terrain.colors(3), horiz=TRUE)
# 4 figures arranged in 2 rows and 2 columns
attach(mtcars)
par(mfrow=c(2,2))
plot(wt,mpg, main="Scatterplot of wt vs. mpg")
plot(wt,disp, main="Scatterplot of wt vs disp")
hist(wt, main="Histogram of wt")
boxplot(wt, main="Boxplot of wt")

# 3 figures arranged in 3 rows and 1 column
attach(mtcars)
par(mfrow=c(3,1),mar=c(0,0,0,0)) 
hist(wt)
hist(mpg)
hist(disp)

# One figure in row 1 and two figures in row 2
attach(mtcars)
layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))
hist(wt)
hist(mpg)
hist(disp)

# One figure in row 1 and two figures in row 2
# row 1 is 1/3 the height of row 2
# column 2 is 1/4 the width of the column 1 
attach(mtcars)
layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE), 
       widths=c(3,1), heights=c(1,2))
hist(wt)
hist(mpg)
hist(disp)

# Add boxplots to a scatterplot
par(fig=c(0,0.8,0,0.8), new=TRUE)
plot(mtcars$wt, mtcars$mpg, xlab="Car Weight",
     ylab="Miles Per Gallon")
par(fig=c(0,0.8,0.55,1), new=TRUE)
boxplot(mtcars$wt, horizontal=TRUE, axes=FALSE)
par(fig=c(0.65,1,0,0.8),new=TRUE)
boxplot(mtcars$mpg, axes=FALSE)
mtext("Enhanced Scatterplot", side=3, outer=TRUE, line=-3)

############################################################################
# Lattice Examples 
library(lattice) 
attach(mtcars)

# create factors with value labels 
gear.f<-factor(gear,levels=c(3,4,5),
               labels=c("3gears","4gears","5gears")) 
cyl.f <-factor(cyl,levels=c(4,6,8),
               labels=c("4cyl","6cyl","8cyl")) 

# kernel density plot 
densityplot(~mpg, 
            main="Density Plot", 
            xlab="Miles per Gallon")

# kernel density plots by factor level 
densityplot(~mpg|cyl.f, 
            main="Density Plot by Number of Cylinders",
            xlab="Miles per Gallon")

# kernel density plots by factor level (alternate layout) 
densityplot(~mpg|cyl.f, 
            main="Density Plot by Numer of Cylinders",
            xlab="Miles per Gallon", 
            layout=c(1,3))

# boxplots for each combination of two factors 
bwplot(cyl.f~mpg|gear.f,
       ylab="Cylinders", xlab="Miles per Gallon", 
       main="Mileage by Cylinders and Gears", 
       layout=(c(1,3))
       
       # scatterplots for each combination of two factors 
       xyplot(mpg~wt|cyl.f*gear.f, 
              main="Scatterplots by Cylinders and Gears", 
              ylab="Miles per Gallon", xlab="Car Weight")
       
       # 3d scatterplot by factor level 
       cloud(mpg~wt*qsec|cyl.f, 
             main="3D Scatterplot by Cylinders") 
       
       # dotplot for each combination of two factors 
       dotplot(cyl.f~mpg|gear.f, 
               main="Dotplot Plot by Number of Gears and Cylinders",
               xlab="Miles Per Gallon")
       
       # scatterplot matrix 
       splom(mtcars[c(1,3,4,5,6)], 
             main="MTCARS Data")
       
       # Customized Lattice Example
       library(lattice)
       panel.smoother <- function(x, y) {
         panel.xyplot(x, y) # show points 
         panel.loess(x, y)  # show smoothed line 
       }
       attach(mtcars)
       hp <- cut(hp,3) # divide horse power into three bands 
       xyplot(mpg~wt|hp, scales=list(cex=.8, col="red"),
              panel=panel.smoother,
              xlab="Weight", ylab="Miles per Gallon", 
              main="MGP vs Weight by Horse Power")
       # ggplot2 examples
       library(ggplot2) 
       
       # create factors with value labels 
       mtcars$gear <- factor(mtcars$gear,levels=c(3,4,5),
                             labels=c("3gears","4gears","5gears")) 
       mtcars$am <- factor(mtcars$am,levels=c(0,1),
                           labels=c("Automatic","Manual")) 
       mtcars$cyl <- factor(mtcars$cyl,levels=c(4,6,8),
                            labels=c("4cyl","6cyl","8cyl")) 
       
       # Kernel density plots for mpg
       # grouped by number of gears (indicated by color)
       qplot(mpg, data=mtcars, geom="density", fill=gear, alpha=I(.5), 
             main="Distribution of Gas Milage", xlab="Miles Per Gallon", 
             ylab="Density")
       
       # Scatterplot of mpg vs. hp for each combination of gears and cylinders
       # in each facet, transmittion type is represented by shape and color
       qplot(hp, mpg, data=mtcars, shape=am, color=am, 
             facets=gear~cyl, size=I(3),
             xlab="Horsepower", ylab="Miles per Gallon") 
       
       # Separate regressions of mpg on weight for each number of cylinders
       qplot(wt, mpg, data=mtcars, geom=c("point", "smooth"), 
             method="lm", formula=y~x, color=cyl, 
             main="Regression of MPG on Weight", 
             xlab="Weight", ylab="Miles per Gallon")
       
       # Boxplots of mpg by number of gears 
       # observations (points) are overlayed and jittered
       qplot(gear, mpg, data=mtcars, geom=c("boxplot", "jitter"), 
             fill=gear, main="Mileage by Gear Number",
             xlab="", ylab="Miles per Gallon")
       library(ggplot2)
       
       p <- qplot(hp, mpg, data=mtcars, shape=am, color=am, 
                  facets=gear~cyl, main="Scatterplots of MPG vs. Horsepower",
                  xlab="Horsepower", ylab="Miles per Gallon")
       
       # White background and black grid lines
       p + theme_bw()
       
       # Large brown bold italics labels
       # and legend placed at top of plot
       p + theme(axis.title=element_text(face="bold.italic", 
                                         size="12", color="brown"), legend.position="top")
       # Display the Student's t distributions with various
       # degrees of freedom and compare to the normal distribution
       
       x <- seq(-4, 4, length=100)
       hx <- dnorm(x)
       
       degf <- c(1, 3, 8, 30)
       colors <- c("red", "blue", "darkgreen", "gold", "black")
       labels <- c("df=1", "df=3", "df=8", "df=30", "normal")
       
       plot(x, hx, type="l", lty=2, xlab="x value",
            ylab="Density", main="Comparison of t Distributions")
       
       for (i in 1:4){
         lines(x, dt(x,degf[i]), lwd=2, col=colors[i])
       }
       
       legend("topright", inset=.05, title="Distributions",
              labels, lwd=2, lty=c(1, 1, 1, 1, 2), col=colors)

       # Children's IQ scores are normally distributed with a
       # mean of 100 and a standard deviation of 15. What
       # proportion of children are expected to have an IQ between
       # 80 and 120?
       
       mean=100; sd=15
       lb=80; ub=120
       
       x <- seq(-4,4,length=100)*sd + mean
       hx <- dnorm(x,mean,sd)
       
       plot(x, hx, type="n", xlab="IQ Values", ylab="",
            main="Normal Distribution", axes=FALSE)
       
       i <- x >= lb & x <= ub
       lines(x, hx)
       polygon(c(lb,x[i],ub), c(0,hx[i],0), col="red") 
       
       area <- pnorm(ub, mean, sd) - pnorm(lb, mean, sd)
       result <- paste("P(",lb,"< IQ <",ub,") =",
                       signif(area, digits=3))
       mtext(result,3)
       axis(1, at=seq(40, 160, 20), pos=0)

       # Q-Q plots
       par(mfrow=c(1,2))
       
       # create sample data 
       x <- rt(100, df=3)
       
       # normal fit 
       qqnorm(x); qqline(x)
       
       # t(3Df) fit 
       qqplot(rt(1000,df=3), x, main="t(3) Q-Q Plot", 
              ylab="Sample Quantiles")
       abline(0,1)
       # Estimate parameters assuming log-Normal distribution 
       
       # create some sample data
       x <- rlnorm(100)
       
       # estimate paramters
       library(MASS)
       fitdistr(x, "lognormal")

# Mosaic Plot Example
library(vcd)
mosaic(HairEyeColor, shade=TRUE, legend=TRUE)

# Association Plot Example
library(vcd)
assoc(HairEyeColor, shade=TRUE)

# First Correlogram Example
library(corrgram)
corrgram(mtcars, order=TRUE, lower.panel=panel.shade,
         upper.panel=panel.pie, text.panel=panel.txt,
         main="Car Milage Data in PC2/PC1 Order")

# Second Correlogram Example
library(corrgram)
corrgram(mtcars, order=TRUE, lower.panel=panel.ellipse,
         upper.panel=panel.pts, text.panel=panel.txt,
         diag.panel=panel.minmax, 
         main="Car Milage Data in PC2/PC1 Order")

# Third Correlogram Example
library(corrgram)
corrgram(mtcars, order=NULL, lower.panel=panel.shade,
         upper.panel=NULL, text.panel=panel.txt,
         main="Car Milage Data (unsorted)")

# Changing Colors in a Correlogram
library(corrgram) 
col.corrgram <- function(ncol){   
  colorRampPalette(c("darkgoldenrod4", "burlywood1",
                     "darkkhaki", "darkgreen"))(ncol)} 
corrgram(mtcars, order=TRUE, lower.panel=panel.shade, 
         upper.panel=panel.pie, text.panel=panel.txt, 
         main="Correlogram of Car Mileage Data (PC2/PC1 Order)")