#### METADATA ####
# Objective:          Estimate water depth and hydroperiod at a point of known elevation
# Author:             Carmen B. de los Santos - cbsantos@ualg.pt
# Creation:           Seville, 27 March 2020
# Last modification:  Seville, 8 May 2020

#### SETTINGS ####

# libraries
library(readxl)     # to read xlsx
library(lubridate)  # for dates
library(plyr)       # for ddply
library(reshape2)   # shape data  
library(ggplot2)    # for graphing
library(grid)       # idem
library(gridExtra)  # idem
library(scales)     # idem

# clean
rm(list=ls())

# working directory
setwd("~/OneDrive - Universidade do Algarve/02_projects/02_RIAVALUE/07_elevation_carbon_sequestration/estimatehydroperiod")

# theme
default <- theme(plot.background=element_blank()) +
  theme(panel.background=element_rect(fill="white",colour="black")) +
  theme(strip.background=element_blank()) +
  theme(strip.text=element_text(size=9,colour="black",angle=0)) +
  theme(panel.grid.major=element_blank()) +
  theme(panel.grid.minor=element_blank()) +
  theme(axis.text.x=element_text(colour="black",size=10,angle=0)) +
  theme(axis.text.y=element_text(colour="black",size=10,angle=0)) +
  theme(axis.title.x=element_text(size=10,vjust=0.2)) +
  theme(axis.title.y=element_text(size=10)) +
  theme(plot.margin= unit(c(0.5,0.5,0.5,0.5),"lines")) +
  theme(legend.background=element_blank()) +
  theme(legend.key=element_blank()) +
  theme(legend.key.height=unit(0.8,"line")) + 
  theme(legend.text.align=0) +
  theme(plot.title=element_text(size=16,face="bold"))


#### ------------------------------ MODEL -----------------------------------####
#### INPUT - POINTS ####

# load data from master file
data.poi <- read.csv("./inputs/data_points.csv")

#### INPUT - HEIGHTS ####

# load data (contains tide heights from official charts)
data.hei <- read.csv("./inputs/data_heights.csv")
data.hei$datetime <- as.POSIXct(
  data.hei$datetime,
  tz = "UTC")

# check structure
str(data.hei)
data.hei$datetime[[1]] # this must be UTC - checked!

# select data and rename columns
data.hei <- data.hei[,c("datetime","height","tide")]
data.hei$tide[data.hei$tide=="Preia-mar"] <- "high"
data.hei$tide[data.hei$tide=="Baixa-mar"] <- "low"

# calculate minutes from first date
data.hei$timemin <- as.numeric(data.hei$datetime)/60
data.hei$timemin <- data.hei$timemin-as.numeric(as.POSIXct("2017-03-01 00:00",tz="UTC"))/60

# add column day, month, time in hours
data.hei$day   <- day(data.hei$datetime)
data.hei$month <- month(data.hei$datetime)
data.hei$timeh <- data.hei$timemin/60

# check
table(data.hei$tide,useNA="ifany")
ggplot(data.hei,aes(x=timeh,y=height)) +
  geom_point(size=0.8,colour="blue") + 
  geom_line()


#### MODEL-Part 1: CALCULATION INTERPOLATED TIDE HEIGHT ####
# the goal is to interpolate tide heights at 1-min intervals using low/high tide charts.
# month of reference: March 2017.

# create intervals
data.int <- data.frame(datetime=seq(ISOdatetime(2017,2,28,0,0,0,tz="UTC"),
                                    ISOdatetime(2017,4,1,0,0,0,tz="UTC"),
                                    by=60*1)) # time interval in seconds


# calculate minutes from first date
data.int$timemin <- as.numeric(data.int$datetime)/60
data.int$timemin <- data.int$timemin-as.numeric(as.POSIXct("2017-03-01 00:00",tz="UTC"))/60
data.int <- merge(data.int,data.hei,all.x=T)

# correction term for sea level rise since hydrographic zero was set
# approximately 10 cm 
tide.corr <- 0.1

# for each time event (t), i.e. row in data.int, identify previous/posterior tide event (time, height)

DATA.INT <- data.frame(
  "datetime"   = POSIXct(length = nrow(data.int)),
  "timemin"    = numeric(length = nrow(data.int)),
  "prev_event" = character(length = nrow(data.int)),
  "prev_time"  = numeric(length = nrow(data.int)),
  "prev_height"= numeric(length = nrow(data.int)) ,
  "post_event" = character(length = nrow(data.int)),
  "post_time"  = numeric(length = nrow(data.int)),
  "post_height"= numeric(length = nrow(data.int))
)

for (i in 1:nrow(data.int)){
  
  # select time event
  data <- data.int[i,]
  
  # get info previous event
  prev_event <- data.hei[data.hei$timemin <= data$timemin,]
  prev_event <- prev_event[which.max(prev_event$timemin),]
  
  # get info posterior event
  post_event <- data.hei[data.hei$timemin >= data$timemin,]
  post_event <- post_event[which.min(post_event$timemin),]
  
  # add info to data
  DATA.INT[i, ] <- data.frame(data$datetime,
                     data$timemin,
                     prev_event$tide,
                     prev_event$timemin,
                     prev_event$height + tide.corr,
                     post_event$tide,
                     post_event$timemin,
                     post_event$height + tide.corr)

}

# replace
data.int <- DATA.INT

# clean
rm(i,DATA.INT,post_event,prev_event)

# calculate parameters for each point
data.int$par_T <- data.int$post_time-data.int$prev_time   # time (min) between closest event
data.int$par_t <- data.int$timemin - data.int$prev_time   # time (min) from previous event

# calculate estimated height using analitical formula
data.int$height <- with(data.int,ifelse(prev_event==post_event,prev_height,
                                        (prev_height+post_height)/2+(prev_height-post_height)/2*cos((pi*par_t)/par_T)))

# select columns
data.int <- data.int[,c("datetime","timemin","height")]

# check time
data.int$datetime[[1]] 

# add column day, month, time in hours
data.int$day   <- day(data.int$datetime)
data.int$month <- month(data.int$datetime)
data.int$timeh <- data.int$timemin/60

# select data (only March)
data.int <- data.int[data.int$month==3,]

# select columns
data.int <- data.int[c("datetime","day","timemin","timeh","height")]

# check plot (only March)
pdf("./outputs/plots_heights_chart_interpolated.pdf",onefile=TRUE,paper="a4")
ggplot(data.int,aes(x=timeh,y=height)) +
  geom_point(size=0.3) +
  geom_point(data=data.hei[data.hei$month==3,],
             aes(x=timeh,y=height),colour="red",shape=21) +
  facet_wrap(.~day,scales="free_x")
dev.off()

# save
write.csv(data.int,"./outputs/data_heights_interpolated.csv")

#### MODEL-Part 2: CALCULATIONS DEPTHS and HYDROPERIODS ####
# at each point p and time t, I want to estimate the water depth d
# d(p,t) = h(t) - e(p)
# where
    # d(p,t) is depth, in meters, at time t and point p
    # h(t) is the tidal height, in meters, referred to MSL at time t
    # e(p) is the elevation, in meters, referred to MSL at point p

# load data
data.int <- read.csv("./outputs/data_heights_interpolated.csv")
data.hei <- read.csv("./inputs/data_heights.csv")
data.poi <- read.csv("./inputs/data_points.csv")

# preparations for loop
pdf("./outputs/plots_hydroperiod_days.pdf",onefile=TRUE,paper="a4")
par(mfrow=c(3,3),pty="s",las=1,oma=c(1,1,1,1),mar=c(5,5,3,1))

points    <- unique(data.poi$point)
DATA.DEP  <- data.frame() # for depths over 1-min intervals over the month

TABLE.MON <- data.frame() # for montly hydroperiod
TABLE.DAY <- data.frame() # for daily hydroperiod
TABLE.SAM <- data.frame() # for sampling days hydroperiod

for (i in 1:length(points)){
  
  ## SELECT POINT
  table.mon <- data.poi[i,]
  
  ## CALCULATE MONTLY HYDROPERIOD FOR EACH POINT
  
  # calculate depth
  data.dep           <- data.int                                 # h(t)
  data.dep$elevation <- table.mon$elevation                      # e(p)
  data.dep$depth     <- with(data.dep,                           # d(p,t) 
                             ifelse(height>elevation,
                                    height-elevation,
                                    0))         

  # add info point to data.dep
  data.dep$point <- table.mon$point
  
  # calculate maximum and minimum depths
  table.mon$depth_max <- max(data.dep$depth)
  table.mon$depth_min <- min(data.dep$depth)
  
  # calculate montly hydroperiod (hours/month)
  table.mon$hydroperiod_hmon <- nrow(data.dep[data.dep$depth>0,])/60
  
  # calculate montly hydroperiod (% month)
  table.mon$hydroperiod_mperc <- 100*table.mon$hydroperiod/(31*24)
  
  # bind data
  TABLE.MON <- rbind(TABLE.MON,table.mon)
  DATA.DEP  <- rbind(DATA.DEP,data.dep)
  
  ## CALCULATE DAILY HYDROPERIOD
  for(j in 1:31){
    # select j day
    subset <- data.dep[data.dep$day==j,]
    
    # create table
    table.day     <- data.poi[i,]
    table.day$day <- j
    
    # calculate maximum and minimum depths
    table.day$depth_max <- max(subset$depth)
    table.day$depth_min <- min(subset$depth)
    
    # calcualte hydroperiod
    table.day$hydroperiod_hday <- nrow(subset[subset$depth>0,])/60
    
    # bind data
    TABLE.DAY <- rbind(TABLE.DAY,table.day)
    
    # plot water depth over a day (BLACK)
    plot(x=subset$timemin/60,y=subset$depth,type="l",
         xlab="Time (hours of month)",
         ylab="Water depth (m)",
         ylim=c(-3,3),
         pch=19,col="black")
    # add tide height from interpolations
    lines(x=subset$timemin/60,y=subset$height,col="grey") 
    # add low/high tide from charts (GREY CIRCLES)
    # points(x=data.hei$timemin/60,y=data.hei$height,col="grey")
    # add text point, day, hydroperiod
    mtext(paste0(table.day$point," day ",j," - E = ",round(table.day$hydroperiod_hday,1)),
          side=3,line=0,adj=0,cex=0.8)
    # add elevation line (GREEN LINE)
    abline(a=table.day$elevation,b=0,col="green",lwd=1)
    
  }
  par(mfrow=c(3,3),pty="s",las=1,oma=c(1,1,1,1),mar=c(5,5,3,1))
  
  ## CALCULATE SAMPLING DAYS HYDROPERIOD
    # select days = c(28,29,30)
    subset <- data.dep[data.dep$day %in% c(28, 29, 30),]
    
    # create table
    table.sam     <- data.poi[i,]
    
    # calculate maximum and minimum depths
    table.sam$depth_max <- max(subset$depth)
    table.sam$depth_min <- min(subset$depth)
    
    # calcualte hydroperiod
    table.sam$hydroperiod_hday <- nrow(subset[subset$depth>0,])/60
    
    # bind data
    TABLE.SAM <- rbind(TABLE.SAM,table.sam)

}

# rename
table.mon <- TABLE.MON # table with montly hydroperiod at each point (n = 58)
table.day <- TABLE.DAY # table with daily hydroperiod at each point and day (n = 58*31)
table.sam <- TABLE.SAM # table with daily hydroperiod at each point from 28 to 30 March (n = 58*3)
data.dep  <- DATA.DEP  # data with depth at each point and minute over a month (n = 58*31*1440)

# manage data
data.dep$datetime <- as.POSIXct(data.dep$datetime,format="%Y-%m-%d %H:%M:%S",tz="UTC")
data.dep$datetime[[1]]

# clean
rm(i,j,points,data.poi,data.hei,subset,TABLE.MON,TABLE.DAY,TABLE.SAM,DATA.DEP)
dev.off()
dev.off()

# save data in csv (long-term data storage)
write.csv(table.mon,"./outputs/table_hydroperiod_monthly.csv")
write.csv(table.day,"./outputs/table_hydroperiod_daily.csv")
write.csv(table.sam,"./outputs/table_hydroperiod_sampling_days.csv")
write.csv(data.dep,"./outputs/data_depths_minute.csv")

#### MODEL-Part 3: VISUALISATION ####

# correlation elevation - montly hydroperiod
ggplot(table.mon,aes(x=elevation,y=hydroperiod_hmon)) + 
  geom_point(aes(colour=habitat),shape=21) +
  # geom_smooth(method="lm",se=F) +
  scale_x_continuous("Elevation (m, MSL)") +
  scale_y_continuous("Hydroperiod (hours month-1)") +
  facet_wrap(~habitat)

ggplot(table.mon,aes(x=elevation,y=hydroperiod_mperc)) + 
  geom_point(aes(colour=habitat),shape=21) +
  # geom_smooth(method="lm",se=F) +
  scale_x_continuous("Elevation (m, MSL)") +
  scale_y_continuous("Hydroperiod (% month)",limits=c(0,100),breaks=c(seq(0,100,25))) +
  facet_wrap(~habitat)

# hydroperiod over month
table <- table.day[table.day$site=="S1",]
ggplot(table,aes(x=day,y=hydroperiod_hday,colour=point)) +
  geom_point(size=0.2) + geom_line() +
  scale_x_continuous("Day (March 2017)") +
  scale_y_continuous("Hydroperiod (hours day-1)") +
  facet_wrap(~transect)

table <- table.day[table.day$site=="S2",]
ggplot(table,aes(x=day,y=hydroperiod_hday,colour=point)) +
  geom_point(size=0.2) + geom_line() +
  scale_x_continuous("Day (March 2017)") +
  scale_y_continuous("Hydroperiod (hours day-1)") +
  facet_wrap(~transect)

table <- table.day[table.day$site=="S3",]
ggplot(table,aes(x=day,y=hydroperiod_hday,colour=point)) +
  geom_point(size=0.2) + geom_line() +
  scale_x_continuous("Day (March 2017)") +
  scale_y_continuous("Hydroperiod (hours day-1)") +
  facet_wrap(~transect)
  
table <- table.day[table.day$site=="S4",]
ggplot(table,aes(x=day,y=hydroperiod_hday,colour=point)) +
  geom_point(size=0.2) + geom_line() +
  scale_x_continuous("Day (March 2017)") +
  scale_y_continuous("Hydroperiod (hours day-1)") +
  facet_wrap(~transect)

rm(table,table.mon,table.day)

#### ------------------------------ VALIDATION ------------------------------####
#### COMPARISON DEPTHS  ####

## DATA OBSERVED
# load data
# file missing
data.obs <- read.csv("./inputs/data_depths.csv")
data.obs$datetime <- as.POSIXct(data.obs$datetime, tz = "UTC")

# know start/end time
data.obs$datetime[1]
data.obs$datetime[nrow(data.obs)]

# select 24 hours ("2017-03-30 09:30:00 UTC" to "2017-03-31 09:30:00 UTC")
data.obs <- data.obs[data.obs$datetime<as.POSIXct("2017-03-31 09:31:00",tz="UTC"),]

# check start/end time
data.obs$datetime[1]
data.obs$datetime[nrow(data.obs)]

## DATA MODEL
# select points Zn3_0 and Zn3_30 in data.dep
data.mod <- data.dep[data.dep$point=="Zn3_0" | data.dep$point=="Zn3_30",]

# select 24 hours ("2017-03-30 09:30:00 UTC" to "2017-03-31 09:30:00 UTC")
data.mod <- data.mod[data.mod$datetime>=as.POSIXct("2017-03-30 09:30:00",tz="UTC"),]
data.mod <- data.mod[data.mod$datetime<=as.POSIXct("2017-03-31 09:30:00",tz="UTC"),]

# check start/end time
data.mod$datetime[1]
data.mod$datetime[nrow(data.mod)]

# check
ggplot(data.mod,aes(x=datetime,y=depth)) +
  geom_line() +
  facet_wrap(~point)

ggplot(data.obs,aes(x=datetime,y=depth)) +
  geom_line() +
  facet_wrap(~point)

## COMPARE DATA
# define subset mod to merge
subset.mod <- data.mod[,c("point","datetime","depth")]
subset.mod$set <- "model"
subset.obs <- data.obs[,c("point","datetime","depth")]
subset.obs$set <- "observed"
data.com <- rbind(subset.obs,subset.mod)
rm(subset.mod,subset.obs)

# plot comaprison depths model-field
fig_s2 <- ggplot(data.com,aes(x=datetime,y=depth,colour=set)) +
  geom_line() +
  facet_wrap(~point) +
  default +
  theme(axis.text.x=element_text(colour="black",size=10,angle=90))
fig_s2

svg(file="outputs/plot_fig_s2.svg",
    width=8,height=5)
grid.arrange(fig_s2,top="")
dev.off()

#### COMPARISON HYDROPERIOD ####

# set loop to calculate daily hydroperiod (hours day-1)
data.com$set_point <- with(data.com,paste0(set,"_",point))
set_points         <- unique(data.com$set_point)
table.com          <- data.frame()

for(i in 1:length(set_points)){
  
  # select data for a set_point
  data <- data.com[data.com$set_point==set_points[i],]
  
  # create table
  table <- data.frame(set_point          = set_points[i],
                      set                = unique(data$set),
                      point              = unique(data$point),
                      hydroperiod_hday   = nrow(data[data$depth>0,])/60)
  
  table.com <- rbind(table.com,table)
}

table.com

# clean
rm(i,set_points,data,table,data.obs,data.mod)

# plot
ggplot(table.com,aes(x=point,y=hydroperiod_hday,fill=set)) +
  geom_col(position=position_dodge())

# clean
rm(table.com)
dev.off()

#### END ####
dev.off()
rm(list=ls())
