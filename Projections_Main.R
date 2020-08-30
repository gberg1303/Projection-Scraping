library(tidyverse)
library(dplyr)
library(stringr)
library(gtools)
library(mclust)
library(XML)
library(RCurl)
library(jsonlite)
library(data.table)
library(httr)
library(lpSolveAPI)

### Create the main function.
    # Week = 0 Implies the Preseason Draft Rankikngs
Fantasy_Football_Projections <- function(sources = c("CBS", "ESPN", "FantasySharks", "Sleeper", "Yahoo", "FantasyPros", "NFL"), Week, Season, Scoring = c("PPR", "Standard", "Half", "Custom"), VOR = VOR, MaxBid = FALSE, Keep.Platform.Projections = FALSE, Proper.Floors = FALSE,
                                         Predictions = FALSE) {
  
### Set Week and Season and Scoring Setting
  assign("sources", sources, envir = .GlobalEnv)
  assign("Scoring", Scoring, envir = .GlobalEnv)
  assign("VOR", VOR, envir = .GlobalEnv)
  assign("week", Week, envir = .GlobalEnv)
  assign("season", Season, envir = .GlobalEnv)
  assign("MaxBid", MaxBid, envir = .GlobalEnv)
  assign("Keep.Platform.Projections", Keep.Platform.Projections, envir = .GlobalEnv)
  assign("Proper.Floors", Proper.Floors, envir = .GlobalEnv)
  assign("Predictions", Predictions, envir = .GlobalEnv)
  
### Source the Projection Files
  ifelse(sources == "CBS", source(paste0(getwd(), '/Scraping Scripts/CBS Projections v1.R'), echo=TRUE), print(sources))
  ifelse(sources == "ESPN" | Proper.Floors == TRUE, source(paste0(getwd(), '/Scraping Scripts/ESPN Projections v1.R'), echo=TRUE), print(sources))
  ifelse(sources == "FantasySharks", source(paste0(getwd(), '/Scraping Scripts/FantasySharks Projections v1.R'), echo=TRUE), print(sources))
  ifelse(sources == "Sleeper", source(paste0(getwd(), '/Scraping Scripts/Sleeper Projections v1.R'), echo=TRUE), print(sources))
  ifelse(sources == "Yahoo", source(paste0(getwd(), '/Scraping Scripts/Yahoo Projections v1.R'), echo=TRUE), print(sources))
  ifelse(sources == "FantasyPros", source(paste0(getwd(), '/Scraping Scripts/FantasyPros Projections v1.R'), echo=TRUE), print(sources))
  ifelse(sources == "NFL", source(paste0(getwd(), '/Scraping Scripts/NFL Projections v1.R'), echo=TRUE), print(sources))

### Load Settings
source(paste0(getwd(), '/Scoring Settings.R'), echo=TRUE)
source(paste0(getwd(), '/Value Over Replacement Settings.R'), echo=TRUE)

### Combine the Projections and Clean Combined Projections
source(paste0(getwd(), '/File Management/Clean Combined Projections.R'), echo=TRUE)

### Score Fantasy Points Based on League Settings
source(paste0(getwd(), '/Calculations/Invididual Fantasy Points.R'), echo=TRUE)


### Average the Statistics 
source(paste0(getwd(), '/Calculations/Average Projections.R'), echo=TRUE)

### Add Advanced Metrics to the Fantasy Projections
source(paste0(getwd(), '/Calculations/Average Fantasy Points.R'), echo=TRUE)
source(paste0(getwd(), '/Calculations/Risk.R'), echo=TRUE)
source(paste0(getwd(), '/Calculations/Value Over Replacement.R'), echo=TRUE)
source(paste0(getwd(), '/Calculations/Cost.R'), echo=TRUE)
source(paste0(getwd(), '/Calculations/Tiers.R'), echo=TRUE)
source(paste0(getwd(), '/Calculations/Dropoff.R'), echo=TRUE)
  
### Load Dependent Function
if(MaxBid == TRUE){source(paste0(getwd(), "/Dependent Files/Create Train.R"))}
if(MaxBid == TRUE){source(paste0(getwd(), "/Dependent Files/Find_Team.R"))}
if(MaxBid == TRUE){source(paste0(getwd(), "/Dependent Files/Setplayers.R"))}
ifelse(MaxBid == TRUE, source(paste0(getwd(), '/Calculations/Bid Up To.R')), print(MaxBid))
  
### Condense and Finish
source(paste0(getwd(), '/File Management/Finalize Projections.R'), echo=TRUE)

### Create Projections
if(Predictions == TRUE & week == 0){source(paste0(getwd(), '/Calculations/Odds Prediction.R'))}

### Remove the Extras
source(paste0(getwd(), '/File Management/Remove Values.R'), echo=TRUE)
}
