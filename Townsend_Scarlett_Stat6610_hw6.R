library(portfolio)

posts <- read.csv("http://datasets.flowingdata.com/post-data.txt")

map.market(id=posts$id, area=posts$views, group=posts$category, color=posts$comments, main="FlowingData Map")

# Mosaic Plot Example
library(vcd)
mosaic(HairEyeColor, shade=TRUE, legend=TRUE)