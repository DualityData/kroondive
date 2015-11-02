library(data.table)
all = fread('usage_clean.csv')
colnames(all)

type = all[,c(1,2,3,4),with=FALSE]

system = all[,c(1,5:10),with=FALSE]

light = all[,c(1,11:15),with=FALSE]

plug = all[,c(1,16:20),with=FALSE]

temp = all[,c(1,21:22),with=FALSE]

michellehudson.github.io/monstermashup2015
national ufo reporting center. 
