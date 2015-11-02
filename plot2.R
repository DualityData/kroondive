rm(list = ls())
library(foreign)
library(reshape2)
library(data.table)
library(plyr)
setwd("C:/Users/lgoin.IPA/Desktop")
survey <- read.csv("sus_surveydata.csv")
usage <- read.csv("usage_clean.csv")

# plot = type by floor
todrop <- grep("^kspace_", colnames(survey), value = TRUE)
data <- survey[, c(todrop, "id")]
data <- melt(data, id.vars = "id",)
data <- data[complete.cases(data),]
data <- with(data,cbind(id, value,colsplit(data$variable,pattern="_",names=c('building','floor','room'))))

data = data.table(data)
byroom = data[,length(unique(id)),by=c("value", "floor", "room")]
byroom <- byroom[value!=0]
byfloor = data[value!=0,length(unique(id)),by=c("floor")]

library(lubridate)
usage <- data.table(usage)
usage[,dt:=as.Date(dt)]
lastyear <- usage[year(dt)==2014]
lastyear[,dt:=NULL]
mean(lastyear)
use = data.frame(colMeans(lastyear))

todrop <- grep("^lighting|^plug", row.names(use), value = TRUE)
trans <- t(as.matrix(use))
use2 <- data.frame(trans[,todrop])

#split into lighting and plug
lighting <- data.frame(use2[1:5,])
floor <- c(-1,0,1,2,3)
lighting <- cbind(lighting,floor)

plug <- data.frame(use2[6:10,])
plug <- cbind(plug, floor)

lighting.byfloor <- merge(x = lighting, y = byfloor, by = "floor")
colnames(lighting.byfloor) <- c("floor", "lighting", "count")

plug.byfloor <- merge(x = plug, y = byfloor, by = "floor")
colnames(plug.byfloor) <- c("floor", "plug", "count")

lighting.byroom <- merge(x = lighting, y = byroom, by = "floor")
colnames(lighting.byroom) <- c("floor", "lighting", "value", "room", "count")

plug.byroom <- merge(x = plug, y = byroom, by = "floor")
colnames(plug.byroom) <- c("floor", "plug", "value", "room", "count")


# stopped here
temp = with(meanusage2014,cbind(use, colsplit(meanusage2014$var,pattern="_",names=c('system','floor','room'))))



