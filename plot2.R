rm(list = ls())
library(foreign)
library(reshape2)
library(data.table)
library(plyr)
setwd("C:/Users/lgoin.IPA/Desktop")
survey <- read.csv("sus_surveydata.csv")
usage <- read.csv("usage_clean.csv")

#get the kspace variables only
tokeep <- grep("^kspace_", colnames(survey), value = TRUE)
data <- survey[, c(tokeep, "id")]
#reshape to long format
data <- melt(data, id.vars = "id",)
data <- data[complete.cases(data),]
#split kspace variable into building, foor, room values. 
#cleaning
data = data.table(data)
data[variable=='kspace_3_byo_cafe',variable:='kspace_3_byocafe']
data[(variable=='kspace_1_bath_f' | variable == 'kspace_1_bath_m'),variable:='kspace_1_bath']
data[variable=='kspace_2_bath_f',variable:='kspace_2_bath']
data[variable=='kspace_2_stairs_c',variable:='kspace_2_stairs']

data <- with(data,cbind(id, value,colsplit(data$variable,pattern="_",names=c('building','floor','room','other'))))

#more cleaning
data = data.table(data)
data[room=='stair',room:='stairs']
data[room=='studyroos',room:='study']
data[room=='classroom',room:='classrooms']

#count number of people to use, by floor and room. 
byfloorroom = data[value!=0,length(unique(id)),by=c("floor", "room")][order(-V1)]
#count number of people to use, by floor
byfloor = data[value!=0,length(unique(id)),by=c("floor")]
#count number of people to use, by room
byroom = data[value!=0,length(unique(id)),by=c("room")][order(-V1)]
#count numbe of people to use, by direction/position of room
byfloordirection = data[value!=0 & other!='',length(unique(id)),by=c("floor","other")][order(-V1)]

#merge in usage data by floor.
#only have by floor data for lighting and plug_load
library(lubridate)
usage <- data.table(usage)
usage[,dt:=as.Date(dt)]
#average over the most recent year
lastyear <- usage[year(dt)==2014]
lastyear[,dt:=NULL]
use = data.frame(colMeans(lastyear))

tokeep <- grep("^lighting|^plug", row.names(use), value = TRUE)
trans <- t(as.matrix(use)) #transpose
use2 <- data.frame(trans[,tokeep])

#split into lighting and plug
lighting <- data.frame(use2[1:5,])
floor <- c(-1,0,1,2,3)
lighting <- cbind(lighting,floor)

plug <- data.frame(use2[6:10,])
plug <- cbind(plug, floor)

#merge together - drops basement. 
lighting.byfloor <- merge(x = lighting, y = byfloor, by = "floor")
colnames(lighting.byfloor) <- c("floor", "lighting", "count")

plug.byfloor <- merge(x = plug, y = byfloor, by = "floor")
colnames(plug.byfloor) <- c("floor", "plug", "count")

lighting.byroom <- merge(x = lighting, y = byfloorroom, by = "floor")
colnames(lighting.byroom) <- c("floor", "lighting", "room", "count")

plug.byroom <- merge(x = plug, y = byfloorroom, by = "floor")
colnames(plug.byroom) <- c("floor", "plug", "room", "count")

degrees <- as.integer(c(0,45,90,135,180,225,270,315))
other <- c("n" ,"ne" ,"e","se","s","sw","w","nw")
degrees <- data.frame(cbind(degrees,other))
degrees$degrees <- as.numeric(levels(degrees$degrees))[degrees$degrees]

bydirection = data[value!=0 & other!='',length(unique(id)),by="other"][order(-V1)]
bydirection <- merge(bydirection, degrees, by = "other")

#### plots

## room occupants by direction
library(ggplot2)
p <-  ggplot(bydirection, aes(x=degrees, y=V1)) 

require(grid)

p + geom_segment(aes(y=0, xend=degrees, yend=V1), color = "salmon", size = bydirection$V1/25) + coord_polar() +
  ggtitle("Number of respondents that frequently use rooms by room orientation") +
  scale_x_continuous("", limits = c(0,360), breaks = seq(0,360-1,45), labels = c("N", "NE", "E", "SE", "S", "SW", "W", "NW")) +
  ylab("")

ggsave("polarplot.png")


## per person usage 
data1 = rbind(lighting.byfloor,plug.byfloor)
data1$perperson = data1$usage/data1$count
data1 = melt(data1,id.vars=c("floor","type"))
data1 = data.table(data1)

g1 = ggplot(data1[type=='lighting'],aes(x=as.factor(floor),y=value,fill=as.factor(floor),alpha=0.5))+geom_bar(stat='identity')+facet_wrap(~variable,nrow=4,scales="free")+theme(legend.position='none',strip.text.x = element_text(size=14,face='bold'))+ggtitle('Lighting energy use')
pdf('lighting.pdf')
print(g1)
dev.off()

g2 = ggplot(data1[type=='plug.load'],aes(x=as.factor(floor),y=value,fill=as.factor(floor),alpha=0.5))+geom_bar(stat='identity')+facet_wrap(~variable,nrow=4,scales="free")+theme(legend.position='none',strip.text.x = element_text(size=14,face='bold'))+ggtitle('Plug-load energy use')
pdf('plug.pdf')
print(g2)
dev.off()

#table - occupants per room
byroom[order(-V1)]

