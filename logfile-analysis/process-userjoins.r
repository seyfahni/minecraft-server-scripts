#!/usr/bin/r

# Uncomment this and comment out the following imports when using the complete tidyverse library
#library(tidyverse)
library(readr)
library(tibble)

dataFiles <- list.files(pattern = "\\.csv$")
csvDataList = list()
for (dataFile in dataFiles) {
    csvDataList[[length(csvDataList) + 1]] <- read_csv(dataFile, col_types = cols(date = col_datetime(format = "%Y-%m-%dT%H:%M:%S+02:00")))
}

datetime <- list()
online <- list()
for (singleRun in csvDataList) {
    datetime <- c.POSIXct(datetime, singleRun$date)
    lastValue <- 0
    for (joinOrLeave in singleRun$action) {
        lastValue <- lastValue + ifelse(joinOrLeave == "logged in", 1, -1)
        online[[length(online) + 1]] <- lastValue
    }
}

df <- data.frame(DateTime=datetime, OnlinePlayers=unlist(online))
# Uncomment this if you want to slice the data to e.g. only include data since some date
#dfSlice <- subset(df, DateTime > as.POSIXct("2020-07-18", "CEST"))

write.csv(df, "analysis.csv", row.names = TRUE)

# Uncomment this (and change values) when creating plots inside RStudio
#dev.new(width = 50, height = 10)
#plot(df, type="s", xlab = "Date and Time", ylab = "Online Players", yaxp = c(0, 40, 8))
