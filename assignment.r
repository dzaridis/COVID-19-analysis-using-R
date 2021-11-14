---
title: "R assignment"
output: html_notebook
---
```{r}
install.packages("ggplot2")
install.packages("data.table")
library(data.table)
```

```{r}
rm(list=ls())
## Loading the data and the necessary libraries(ggplot and data.table)

covid_confirmed<-fread("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv")
covid_deaths<-fread("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")

```
```{r}
##task 1 removing the columns
selected_deaths<-covid_deaths[,c("Province/State","Lat","Long"):=NULL]
selected_confirmed<-covid_confirmed[,c("Province/State","Lat","Long"):=NULL]

##task 2 conversion to long format
selected_deaths_long<-melt(selected_deaths)
selected_confirmed_long<-melt(selected_confirmed)

##task 3 renaming the column country region to country
setnames(selected_deaths,c("Country/Region"),c("Country"))
setnames(selected_confirmed,c("Country/Region"),c("Country"))
setnames(selected_deaths_long,c("Country/Region"),c("Country_deaths"))
setnames(selected_confirmed_long,c("Country/Region"),c("Country_conf"))


##task4 cumulative confirmed cases and deaths
#deaths<-rowSums(selected_deaths[1:length(selected_deaths),2:length(selected_deaths)])
deaths<-selected_deaths_long[,.(deaths=sum(value))]
confirmed<-selected_confirmed_long[,.(confirmed=sum(value))]
cum_deaths<-cbind(selected_deaths_long,deaths)
cum_confirmed<-cbind(selected_confirmed_long,confirmed)

##task5 Date conversion. Caps Y means that century preceed of the year 20 for century 20 for year(2020 or 2021) while y puts only year of the current century(20 or 21)
cum_deaths$variable<-format(as.Date(cum_deaths$variable,format="%m/%d/%y"),"%d/%m/%Y")
cum_confirmed$variable<-format(as.Date(cum_confirmed$variable,format="%m/%d/%y"),"%d/%m/%Y")
setnames(cum_deaths,c("variable"),c("Date_deaths"))
setnames(cum_confirmed,c("variable"),c("Date_conf"))

#task6 groupby country and date
d<-cum_deaths[,value,by=.(Country_deaths,Date_deaths)]
c<-cum_confirmed[,value,by=.(Country_conf,Date_conf)]
print(head(d))

#task7 #merging the original and the long formatted dataset
#before we merge the two datasets we need to define two columns (deaths and confirm cases in order that we are going to be able to discrete values)
setnames(d,c("value"),c("Deaths"))
setnames(c,c("value"),c("Confirmed"))
total <- cbind(d,c)
#we drop one country and date column because we don t need them 
total$Country_deaths<-NULL
total$Date_deaths<-NULL
setnames(total,c("Date_conf"),c("Date"))
setnames(total,c("Country_conf"),c("Country"))
### merge the original dataset
total_or<-rbind(selected_deaths,selected_confirmed)

#task8 from the long formatted datasets we find the sum of every row of the column value
deaths<-selected_deaths_long[,.(deaths=sum(value))]
confirmed<-selected_confirmed_long[,.(confirmed=sum(value))]

#task9 sorting
total_ordered<-total[order(Country,as.Date(total$Date,format = "%d/%m/%Y")),]

#task10 confirmed.ind & deaths.inc on a daily basis from original datasets as they are more helpfull than the long formatted
selected_confirmed_ind<-selected_confirmed[,lapply(.SD, sum),.SDcols=c(2:length(selected_confirmed))]
selected_deaths_inc<-selected_deaths[,lapply(.SD, sum),.SDcols=c(2:length(selected_deaths))]
selected_confirmed_ind<-data.table("Cumulative confirmed cases",selected_confirmed_ind)
selected_deaths_inc<-data.table("Cumulative death cases",selected_deaths_inc)
setnames(selected_confirmed_ind,c("V1"),c("Country"))
setnames(selected_deaths_inc,c("V1"),c("Country"))
cum_conf<-rbind(selected_confirmed,selected_confirmed_ind) #  Adding the cumulative daily cases per day
cum_deaths<-rbind(selected_deaths,selected_deaths_inc) #  Adding the cumulative daily deaths per day
```