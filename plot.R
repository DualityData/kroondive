#some plots

setwd("C:/Users/ifalomir/Desktop/Data hack")

energy<-read.csv("usage_clean.csv")

library("ggplot2")
library("lubridate")

energy$dt<-as.Date(energy$dt)

#Some practice plots
with(energy, plot(dt, type_solar, main="Solar"))+geom_line()
ggplot(energy,aes(x=dt, y=type_solar))+geom_line()+geom_point()

energy$season<-ifelse(month(energy$dt) %in% c(3,4,5), "spring", 
              energy$season<-ifelse(month(energy$dt) %in% c(6,7,8), "summer",
              energy$season<-ifelse(month(energy$dt) %in% c(9,10,11), "fall",
              energy$season<-ifelse(month(energy$dt) %in% c(12,1,2), "winter", "NA"))))


## coorelations
lm(type_total ~ temp_avg_outside, data=energy)
ggplot(energy,aes(x=temp_avg_outside, y=type_total,colour=season))+geom_smooth(method=lm,se=FALSE)+geom_point()
ggplot(energy,aes(x=temp_avg_outside, y=system_hot_water))+geom_smooth(method=lm,se=FALSE)+geom_point()


## Nice one!!!!

# general
total<-ggplot(energy,aes(x=dt, y=type_total))+geom_smooth(method=lm,se=FALSE)+
        geom_point()+geom_line()+xlab("Time")+ ylab("Total energy")+
        ggtitle("Usage of energy over time")
solar<-ggplot(energy,aes(x=dt, y=type_solar))+geom_smooth(method=lm,se=FALSE)+
        geom_point()+geom_line()+xlab("Time")+ ylab("Solar")+
        ggtitle("Usage of Solar over time")
hot_water<-ggplot(energy,aes(x=dt, y=system_hot_water))+
            geom_smooth(method=lm,se=FALSE)+geom_point()+
            geom_line()+xlab("Time")+ ylab("Hot Water")+
            ggtitle("Usage of hot water over time")

# to look at graph just write name in the console


## by season
total_s<-ggplot(energy,aes(x=dt, y=type_total,colour=season))+
          geom_smooth(method=lm,se=FALSE)+geom_point()+
          xlab("Time")+ ylab("Total")+
          ggtitle("Usage of energy over time by season")
ggsave(file="total_season.png")

solar_s<-ggplot(energy,aes(x=dt, y=type_solar,colour=season))+
          geom_smooth(method=lm,se=FALSE)+geom_point()+
          xlab("Time")+ ylab("Solar")+
          ggtitle("Usage of solar over time by season")
ggsave(file="solar_season.png")

hot_water_s<-ggplot(energy,aes(x=dt, y=system_hot_water,colour=season))+
          geom_smooth(method=lm,se=FALSE)+geom_point()+
          xlab("Time")+ ylab("Hot Water")+
          ggtitle("Usage of hot water over time by season")
ggsave(file="water_season.png")

heat_s<-ggplot(energy,aes(x=dt, y=system_heat_pumps,colour=season))+
      geom_smooth(method=lm,se=FALSE)+geom_point()+
      xlab("Time")+ ylab("Heat")+
      ggtitle("Usage of heat pumps over time by season")
ggsave(file="heat_season.png")

## Use by floor (I still want to put this 2 graphs together)
light_0<-ggplot(energy,aes(x=dt, y=lighting_base))+geom_smooth(method=lm,se=FALSE)+geom_point()+geom_line()
light_1<-ggplot(energy,aes(x=dt, y=lighting_ground))+geom_smooth(method=lm,se=FALSE)+geom_point()+geom_line()

library("ggvis")

energy %>% ggvis(~dt, ~system_hot_water) %>% layer_points() %>% layer_smooths(span = input_slider(0.5, 1, value = 1))
energy %>% ggvis(~dt, ~system_hot_water, fill = ~temp_avg_outside, size = ~temp_avg_indoor) %>% 
    layer_points() %>% layer_smooths(span = input_slider(0.5, 1, value = 1))

hotwater_interactive<-energy %>% ggvis(~dt, ~system_hot_water, fill = ~temp_avg_outside) %>% 
  layer_points() %>% layer_smooths(span = input_slider(0.5, 1, value = 1)) %>%
  add_axis("x", title = "Time") %>%
  add_axis("y", title = "Hot water")

heat_interactive<-energy %>% ggvis(~dt, ~system_heat_pumps, fill = ~temp_avg_outside) %>% 
  layer_points() %>% layer_smooths(span = input_slider(0.5, 1, value = 1)) %>%
  add_axis("x", title = "Time") %>%
  add_axis("y", title = "Heat pumps")

