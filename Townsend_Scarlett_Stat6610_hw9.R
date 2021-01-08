#Activity 0

library(hts)

# Example 1
# The hierarchical structure looks like 2 child nodes associated with level 1,
# which are followed by 3 and 2 sub-child nodes respectively at level 2.

nodes <- list(2, c(3, 2))
abc <- ts(5 + matrix(sort(rnorm(500)), ncol = 5, nrow = 100))
x <- hts(abc, nodes)

# etc

fc <- forecast(x, h=10, fmethod="ets", parallel=TRUE, num.cores=2)

plot(fc)

# arima

fc <- forecast(x, h=10, fmethod="arima", parallel=TRUE, num.cores=4)

plot(fc)


# Example 2
# Suppose we've got the bottom names that can be useful for constructing the node
# structure and the labels at higher levels. We need to specify how to split them 
# in the argument "characters".

abc <- ts(5 + matrix(sort(rnorm(1000)), ncol = 10, nrow = 100))
colnames(abc) <- c("A10A", "A10B", "A10C", "A20A", "A20B",
                   "B30A", "B30B", "B40A", "B40B", "B40C")
y <- hts(abc, characters = c(1, 2, 1))

# etc

fc <- forecast(y, h=10, fmethod="ets", parallel=TRUE, num.cores=2)

plot(fc)

# arima

fc <- forecast(y, h=10, fmethod="arima", parallel=TRUE, num.cores=4)

plot(fc)

#Activity 1
### Heatmap
bball <- read.csv("http://datasets.flowingdata.com/ppg2008.csv", header=TRUE)

# Ordering
bball <- bball[order(bball$PTS),]
bball_byfgp <- bball[order(bball$FGP, decreasing=TRUE),]

row.names(bball) <- bball$Name
bball <- bball[,2:20]
bball_matrix <- data.matrix(bball)

bball_heatmap <- heatmap(bball_matrix, Rowv=NA, Colv=NA, col = cm.colors(256), scale="column", margins=c(5,10))
bball_heatmap <- heatmap(bball_matrix, Rowv=NA, Colv=NA, col = heat.colors(256), scale="column", margins=c(5,10))

# Custom colors
red_colors <- c("#ffd3cd", "#ffc4bc", "#ffb5ab", "#ffa69a", "#ff9789", "#ff8978", "#ff7a67", "#ff6b56", "#ff5c45", "#ff4d34")
bball_heatmap <- heatmap(bball_matrix, Rowv=NA, Colv=NA, col = red_colors, scale="column", margins=c(5,10))

library(RColorBrewer)
bball_heatmap <- heatmap(bball_matrix, Rowv=NA, Colv=NA, col = brewer.pal(9, "Blues"), scale="column", margins=c(5,10))

#Activity 2
### Chernoff
library(aplpack)
bball <- read.csv("http://datasets.flowingdata.com/ppg2008.csv", header=TRUE)
bball[1:5,]
faces(bball[,2:16])
faces(bball[,2:16], labels=bball$Name)

#Activity 3
### Stars
crime <- read.csv("http://datasets.flowingdata.com/crimeRatesByState-formatted.csv")
stars(crime)
row.names(crime) <- crime$state
crime <- crime[,2:7]
stars(crime, flip.labels=FALSE, key.loc = c(15, 1.5))
stars(crime, flip.labels=FALSE, key.loc = c(15, 1.5), full=FALSE)
stars(crime, flip.labels=FALSE, key.loc = c(15, 1.5), draw.segments=TRUE)

#Activity 4
### Parallel Coordinates Plot
education <- read.csv("http://datasets.flowingdata.com/education.csv", header=TRUE)
education[1:10,]

library(lattice)
parallel(education)
parallel(education, horizontal.axis=FALSE)
parallel(education[,2:7], horizontal.axis=FALSE)
parallel(education[,2:7], horizontal.axis=FALSE, col="#000000")

# Quartiles
summary(education)

# Color by reading SAT
reading_colors <- c()
for (i in 1:length(education$state)) {
  
  if (education$reading[i] > 523) {
    col <- "#000000"	
  } else {
    col <- "#cccccc"	
  }
  reading_colors <- c(reading_colors, col)
}
parallel(education[,2:7], horizontal.axis=FALSE, col=reading_colors)

# Color by dropout rate
dropout_colors <- c()
for (i in 1:length(education$state)) {
  
  if (education$dropout_rate[i] > 5.3) {
    c <- "#000000"	
  } else {
    c <- "#cccccc"	
  }
  dropout_colors <- c(dropout_colors, c)
}
parallel(education[,2:7], horizontal.axis=FALSE, col=dropout_colors)

## ggparallel

library(ggplot2)
library(ggparallel)

# Examples

data(mtcars)

ggparallel(list("gear", "cyl"), data=mtcars)
ggparallel(list("gear", "cyl"), data=mtcars, method="hammock")

## combination of common angle plot and hammock adjustment:
ggparallel(list("gear", "cyl"), data=mtcars, method="adj.angle")

## compare with method='parset'
ggparallel(list("gear", "cyl"), data=mtcars, method='parset')

## flip plot and rotate text
ggparallel(list("gear", "cyl"), data=mtcars, text.angle=0) + coord_flip()

## change colour scheme
ggparallel(list("gear", "cyl"), data=mtcars, text.angle=0) + coord_flip() +
  scale_fill_brewer(palette="Set1") +
  scale_colour_brewer(palette="Set1")

## Example with more than two variables:

titanic <- as.data.frame(Titanic)

ggparallel(names(titanic)[c(1,4,2,1)], order=0, titanic, weight="Freq") +
  scale_fill_brewer(palette="Paired", guide="none") +
  scale_colour_brewer(palette="Paired", guide="none")

## hammock plot with same width lines
ggparallel(names(titanic)[c(1,4,2,3)], titanic, weight=1, asp=0.5, method="hammock", ratio=0.2, order=c(0,0)) +
  theme( legend.position="none") +
  scale_fill_brewer(palette="Paired") +
  scale_colour_brewer(palette="Paired")

## hammock plot with line widths adjusted by frequency
ggparallel(names(titanic)[c(1,4,2,3)], titanic, weight="Freq", asp=0.5, method="hammock", order=c(0,0)) +
  theme( legend.position="none")

## Example biological examples: genes and pathways

data(genes)

genes$chrom <- factor(genes$chrom, levels=c(paste("chr", 1:22, sep=""), "chrX", "chrY"))
ggparallel(list("path", "chrom"), text.offset=c(0.03, 0,-0.03), data = genes, width=0.1, order=c(1,0), text.angle=0, color="white",
           factorlevels = c(sapply(unique(genes$chrom), as.character),
                            unique(genes$path))) +
  scale_fill_manual(values = c( brewer.pal("YlOrRd", n = 9), rep("grey80", 24)), guide="none") +
  scale_colour_manual(values = c( brewer.pal("YlOrRd", n = 9), rep("grey80", 24)), guide="none") +
  coord_flip()

#Activity 5
### Multidimensional scaling
ed.dis <- dist(education[,2:7], method="euclidean")
ed.mds <- cmdscale(ed.dis)
x <- ed.mds[,1]
y <- ed.mds[,2]
plot(x,y)

plot(x, y, type="n")
text(x, y, labels=education$state)
text(x, y, labels=education$state, col=dropout_colors)
text(x, y, labels=education$state, col=reading_colors)

# Clustering
library(mclust)
ed.mclust <- Mclust(ed.mds)
par(mfrow=c(2,2))
plot(ed.mclust, data=ed.mds)
