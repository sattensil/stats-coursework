

library(rCharts)
library(leaflet)

map3 <- Leaflet$new()
map3$setView(c(37.65602,-122.05415), zoom = 13)
map3$marker(c(37.65602,-122.05415), bindPopup = "<p> Hello from CSU East Bay </p>")
map3

map3 <- Leaflet$new()
map3$setView(c(39.904211,116.407395), zoom = 13)
map3$marker(c(39.904211,116.40739), bindPopup = "<p> Hello from Beijing </p>")
map3





library(weatherData)
library(weathermetrics)
library(ggplot2)
data_okay <- checkDataAvailability("LAX", "2016-02-1")

data_okay <- checkSummarizedDataAvailability("LAX","2015-02-01","2016-02-01")

getCurrentTemperature(station_id = "LAX")

wLAX <- getDetailedWeather("LAX", "2016-02-1", opt_all_columns=T)

attach(wLAX)

ggplot(data = wLAX, aes(x=Wind_SpeedMPH, y=WindDirDegrees, color=Wind_Direction)) + geom_point(size=3) + labs(title="LAX Wind")


city1 <- "LAX"
city2 <- "HOU"

df1 <- getWeatherForYear(city1, 2015)

df2 <- getWeatherForYear(city2, 2015)

getDailyDifferences <- function(df1, df2){
  Delta_Means <- df1$Mean_TemperatureF - df2$Mean_TemperatureF
  Delta_Max <- df1$Max_TemperatureF - df2$Max_TemperatureF
  Delta_Min <- df1$Min_TemperatureF - df2$Min_TemperatureF
  
  diff_df <- data.frame(Date=df1$Date, Delta_Means, Delta_Max, Delta_Min)
  return(diff_df)
}

plotDifferences <- function (differences, city1, city2) {
  library(reshape2)
  m.diff <- melt(differences, id.vars=c("Date"))
  p <- ggplot(m.diff, aes(x=Date, y=value)) + geom_point(aes(color=variable)) +  
    facet_grid(variable ~ .) +geom_hline(yintercept=0)
  p <- p + labs(title=paste0("Daily Temperature Differences: ", city1, " minus ",city2))
  print(p)
}

differences<- getDailyDifferences(df1, df2)
plotDifferences(differences, city1, city2)