library(tidyverse)
library(XML)
library(RCurl)
library(gtools)
library(stringr)

### Set Up The Conditionals for the Large Scrape
if(week == 0){week_no <- paste0("S_", season)}
if(week > 0){week_no <- paste0("W_", week)}

### Get the First Table and Clean it UP
pages <- 0
yahoo_url <- getURL(paste0("https://football.fantasysports.yahoo.com/f1/39345/players?status=ALL&pos=O&cut_type=9&stat1=S_P", week_no, "&myteam=0&sort=PR&sdir=1&count=", pages))
projections_yahoo <- readHTMLTable((yahoo_url), stringsAsFactors = FALSE)[2]$'NULL'
colnames(projections_yahoo) <- make.unique(colnames(projections_yahoo))
if(nrow(projections_yahoo) != 25){projections_yahoo <- readHTMLTable((yahoo_url), stringsAsFactors = FALSE)[1]$'NULL'}
if(nrow(projections_yahoo) != 25){projections_yahoo <- readHTMLTable((yahoo_url), stringsAsFactors = FALSE)[3]$'NULL'}
projections_yahoo <-  projections_yahoo[c("Offense", "Owner", "GP*", "Bye","Fan Pts","% Owned","Proj","Actual", "Yds", "TD", "Int",     
                                          "Att*", "Yds.1", "TD.1", "Tgt*", "Rec", "Yds.2", "TD.2", "TD.3", "2PT", "Lost")]
colnames(projections_yahoo) <- c("Player", "Owner", "Games.Played", "Bye", "Fantasy.Points", "Perc.Owned",
                          "Projected.Rank", "Actual.Rank", "Passing.Yards", "Passing.Touchdowns", "Interceptions",
                          "Carries", "Rushing.Yards", "Rushing.Touchdowns", "Targets", "Receptions", "Receiving.Yards",
                          "Receiving.Touchdowns", "Return.Touchdowns", "2PT.Conversion", "Fumbles.Lost")

### Get the Loop
pages <- c(25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 325, 350, 375, 400, 425, 450, 475, 500, 525, 550, 575)
for(pages in pages){
  yahoo_url <- getURL(paste0("https://football.fantasysports.yahoo.com/f1/39345/players?status=ALL&pos=O&cut_type=9&stat1=S_P", week_no, "&myteam=0&sort=PR&sdir=1&count=", pages))
  projections_yahoo_placeholder <- readHTMLTable((yahoo_url), stringsAsFactors = FALSE)[2]$'NULL'
  if(nrow(projections_yahoo_placeholder) != 25){projections_yahoo_placeholder <- readHTMLTable((yahoo_url), stringsAsFactors = FALSE)[1]$'NULL'}
  if(nrow(projections_yahoo_placeholder) != 25){projections_yahoo_placeholder <- readHTMLTable((yahoo_url), stringsAsFactors = FALSE)[3]$'NULL'}
  colnames(projections_yahoo_placeholder) <- make.unique(colnames(projections_yahoo_placeholder))
  if(pages<174) {projections_yahoo_placeholder <- projections_yahoo_placeholder[c("Offense", "Owner", "GP*", "Bye","Fan Pts","% Owned","Proj","Actual", "Yds", "TD", "Int",     
                                                                      "Att*", "Yds.1", "TD.1", "Tgt*", "Rec", "Yds.2", "TD.2", "TD.3", "2PT", "Lost")]
    colnames(projections_yahoo_placeholder) <- c("Player", "Owner", "Games.Played", "Bye", "Fantasy.Points", "Perc.Owned",
                                                 "Projected.Rank", "Actual.Rank", "Passing.Yards", "Passing.Touchdowns", "Interceptions",
                                                 "Carries", "Rushing.Yards", "Rushing.Touchdowns", "Targets", "Receptions", "Receiving.Yards",
                                                 "Receiving.Touchdowns", "Return.Touchdowns", "2PT.Conversion", "Fumbles.Lost")}
  if(pages>174) {projections_yahoo_placeholder <- projections_yahoo_placeholder[c("Offense", "Owner", "GP*", "Bye","Fan Pts","% Owned","Proj","Actual", "Yds", "TD", "Int",     
                                                                                  "Att*", "Yds.1", "TD.1", "Tgt*", "Rec", "Yds.2", "TD.2", "TD.3", "2PT", "Lost")]
  colnames(projections_yahoo_placeholder) <- c("Player", "Owner", "Games.Played", "Bye", "Fantasy.Points", "Perc.Owned",
                                               "Projected.Rank", "Actual.Rank", "Passing.Yards", "Passing.Touchdowns", "Interceptions",
                                               "Carries", "Rushing.Yards", "Rushing.Touchdowns", "Targets", "Receptions", "Receiving.Yards",
                                               "Receiving.Touchdowns", "Return.Touchdowns", "2PT.Conversion", "Fumbles.Lost")}
  projections_yahoo <- smartbind(projections_yahoo, projections_yahoo_placeholder)
}

### Add Kickers 
pages <- c(1, 25)
for(pages in pages){
  yahoo_url <- getURL(paste0("https://football.fantasysports.yahoo.com/f1/39345/players?status=ALL&pos=K&cut_type=9&stat1=S_P", week_no, "&myteam=0&sort=PR&sdir=1&count=", pages))
  projections_yahoo_placeholder <- readHTMLTable((yahoo_url), stringsAsFactors = FALSE)[2]$'NULL'
  if(nrow(projections_yahoo_placeholder) < 20){projections_yahoo_placeholder <- readHTMLTable((yahoo_url), stringsAsFactors = FALSE)[1]$'NULL'}
  if(nrow(projections_yahoo_placeholder) < 20){projections_yahoo_placeholder <- readHTMLTable((yahoo_url), stringsAsFactors = FALSE)[3]$'NULL'}
  if(nrow(projections_yahoo_placeholder) < 20){projections_yahoo_placeholder <- readHTMLTable((yahoo_url), stringsAsFactors = FALSE)[4]$'NULL'}
  if(pages<24) {projections_yahoo_placeholder <- projections_yahoo_placeholder[c( "Kickers", "Owner", "GP*", "Bye", "Fan Pts", "% Owned", "Proj", "Actual", "0-19", "20-29", "30-39", "40-49", "50+", "Made")]
    colnames(projections_yahoo_placeholder) <- c("Player", "Owner", "Games.Played", "Bye", "Fantasy.Points", "Perc.Owned",
                                                              "Projected.Rank", "Actual.Rank", "FGM.1_19", "FGM.20_29", "FGM.30_39", "FGM.40_49", "FGM.50.", "Field.Goals.Made")}
  if(pages>24) {projections_yahoo_placeholder <- projections_yahoo_placeholder[c( "Kickers", "Owner", "GP*", "Bye", "Fan Pts", "% Owned", "Proj", "Actual", "0-19", "20-29", "30-39", "40-49", "50+", "Made")]
  colnames(projections_yahoo_placeholder) <- c("Player", "Owner", "Games.Played", "Bye", "Fantasy.Points", "Perc.Owned",
                                               "Projected.Rank", "Actual.Rank", "FGM.1_19", "FGM.20_29", "FGM.30_39", "FGM.40_49", "FGM.50.", "Field.Goals.Made")}
  projections_yahoo <- smartbind(projections_yahoo, projections_yahoo_placeholder)
}


### Clean up the Player Name
projections_yahoo$Player <- str_replace_all(projections_yahoo$Player, "\n", "")
projections_yahoo$Player <- str_replace_all(projections_yahoo$Player, "No new player Notes", "")
projections_yahoo$Player <- str_replace_all(projections_yahoo$Player, "player Notes", "")
projections_yahoo$Player <- str_replace_all(projections_yahoo$Player, "Player Notes", "")
projections_yahoo$Player <- str_replace_all(projections_yahoo$Player, "Player Note", "")
projections_yahoo$Player <- str_replace_all(projections_yahoo$Player, "New ", "")

### Remove Funky Characters
projections_yahoo$Player <- str_replace_all(projections_yahoo$Player, "III ", "")
projections_yahoo$Player <- str_replace_all(projections_yahoo$Player, "II ", "")
projections_yahoo$Player <- str_replace_all(projections_yahoo$Player, "Jr.", "")
projections_yahoo$Player <- str_replace_all(projections_yahoo$Player, "Sr.", "")
projections_yahoo$Player <- str_replace_all(projections_yahoo$Player, "IV ", " ")
projections_yahoo$Player <- str_replace_all(projections_yahoo$Player, "V ", " ")
projections_yahoo$Player <- str_replace_all(projections_yahoo$Player, "Vander ", "Vander")
projections_yahoo$Player <- str_replace_all(projections_yahoo$Player, "St. ", "St")
projections_yahoo$Player <- str_replace_all(projections_yahoo$Player, "\\. ", " ")
projections_yahoo$Player <- str_replace_all(projections_yahoo$Player, "\\.", "")

### Extract Position
projections_yahoo$Player <- sub("^\\s*(\\S+\\s+\\S+\\s+\\S+\\s+\\S+\\s+\\S+).*", "\\1", projections_yahoo$Player) ## Clear everything after the Fifth space 
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
projections_yahoo$Position <- str_trim(substrRight(projections_yahoo$Player, 2))

### Extract Team Name
projections_yahoo$Player <- sub("^\\s*(\\S+\\s+\\S+\\s+\\S+).*", "\\1", projections_yahoo$Player) ## Clear everything after the Third space 
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
projections_yahoo$Team <- str_trim(substrRight(projections_yahoo$Player, 3))

### Clean Player Names one last time
projections_yahoo$Player <- sub("^\\s*(\\S+\\s+\\S+).*", "\\1", projections_yahoo$Player) ## Clear everything after the second space 


### Get Auction Value from Yahoo
if(week == 0){
pages <- 0
    yahoo_url <- getURL(paste0("https://football.fantasysports.yahoo.com/f1/draftanalysis?tab=AD&pos=ALL&sort=DA_AP&count=", pages))
    projections_yahoo_AuctionValue <- readHTMLTable((yahoo_url), stringsAsFactors = FALSE)$"draftanalysistable"
    
pages <- c(50, 100, 150, 200)
for(pages in pages){
  yahoo_url <- getURL(paste0("https://football.fantasysports.yahoo.com/f1/draftanalysis?tab=AD&pos=ALL&sort=DA_AP&count=", pages))
  projections_yahoo_AuctionValue_placeholder <- readHTMLTable((yahoo_url), stringsAsFactors = FALSE)$"draftanalysistable"
  projections_yahoo_AuctionValue <- smartbind(projections_yahoo_AuctionValue, projections_yahoo_AuctionValue_placeholder)
}
projections_yahoo_AuctionValue <- projections_yahoo_AuctionValue %>%
  select(Name, `Avg Cost`) %>%
  rename(Player = Name,
         Average.Auction.Value = `Avg Cost`)

### Remove Funky Characters from Auction Value
projections_yahoo_AuctionValue$Player <- str_replace_all(projections_yahoo_AuctionValue$Player, "III ", "")
projections_yahoo_AuctionValue$Player <- str_replace_all(projections_yahoo_AuctionValue$Player, "II ", "")
projections_yahoo_AuctionValue$Player <- str_replace_all(projections_yahoo_AuctionValue$Player, "Jr.", "")
projections_yahoo_AuctionValue$Player <- str_replace_all(projections_yahoo_AuctionValue$Player, "Sr.", "")
projections_yahoo_AuctionValue$Player <- str_replace_all(projections_yahoo_AuctionValue$Player, "IV ", " ")
projections_yahoo_AuctionValue$Player <- str_replace_all(projections_yahoo_AuctionValue$Player, "V ", " ")

### Clean up the Player Name from Auction Value
projections_yahoo_AuctionValue$Player <- str_replace_all(projections_yahoo_AuctionValue$Player, "\n", "")
projections_yahoo_AuctionValue$Player <- str_replace_all(projections_yahoo_AuctionValue$Player, "No new player Notes", "")
projections_yahoo_AuctionValue$Player <- str_replace_all(projections_yahoo_AuctionValue$Player, "player Notes", "")
projections_yahoo_AuctionValue$Player <- str_replace_all(projections_yahoo_AuctionValue$Player, "Player Notes", "")
projections_yahoo_AuctionValue$Player <- str_replace_all(projections_yahoo_AuctionValue$Player, "Player Note", "")
projections_yahoo_AuctionValue$Player <- str_replace_all(projections_yahoo_AuctionValue$Player, "New ", "")

### Extract Position rom Auction Value
projections_yahoo_AuctionValue$Player <- sub("^\\s*(\\S+\\s+\\S+\\s+\\S+\\s+\\S+\\s+\\S+).*", "\\1", projections_yahoo_AuctionValue$Player) ## Clear everything after the Fifth space 
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
projections_yahoo_AuctionValue$Position <- str_trim(substrRight(projections_yahoo_AuctionValue$Player, 2))

### Extract Team Name from Auction Value
projections_yahoo_AuctionValue$Player <- sub("^\\s*(\\S+\\s+\\S+\\s+\\S+).*", "\\1", projections_yahoo_AuctionValue$Player) ## Clear everything after the Third space 
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
projections_yahoo_AuctionValue$Team <- str_trim(substrRight(projections_yahoo_AuctionValue$Player, 3))

### Clean Player Names one last time
projections_yahoo_AuctionValue$Player <- sub("^\\s*(\\S+\\s+\\S+).*", "\\1", projections_yahoo_AuctionValue$Player) ## Clear everything after the second space 

### Remove Dollar Signs from Auction Value
projections_yahoo_AuctionValue$Average.Auction.Value <- gsub("[\\$,]", "", projections_yahoo_AuctionValue$Average.Auction.Value)

### Make Auction Value Numeric
projections_yahoo_AuctionValue$Average.Auction.Value <- as.numeric(projections_yahoo_AuctionValue$Average.Auction.Value)

### Merge Projections and Auction Value
projections_yahoo <- merge(projections_yahoo, projections_yahoo_AuctionValue, by = c("Player", "Position", "Team"), all.x = TRUE, all.y = FALSE)
}

### Rearrange the Columns
projections_yahoo$Platform <- "Yahoo"
projections_yahoo <- projections_yahoo %>%
  select(-Owner, -Fantasy.Points, -Perc.Owned, -Projected.Rank, -Actual.Rank) %>%
  select(Platform, Player, Team, Position, everything())

### Make Numeric
if(week == 0){projections_yahoo[5:26] <- as.numeric(unlist(projections_yahoo[5:26]))}
if(week > 0){projections_yahoo[5:25] <- as.numeric(unlist(projections_yahoo[5:25]))}

### Combine Kicker Columns
projections_yahoo <- projections_yahoo %>%
  mutate(`FGM.1_39` = (`FGM.1_19`+`FGM.20_29`+`FGM.30_39`)) %>%
  select(-FGM.1_19, -FGM.20_29, -FGM.30_39)  

### Change Jacksonville Team Name
projections_yahoo$Team[projections_yahoo$Team == "Jax"] <- "JAC"

### Clean, Save, and Call it a Day
if(week == 0){week_no <- paste0("Draft")}
if(week > 0){week_no <- paste0(week)}
assign(paste0("Yahoo_Projections"), projections_yahoo)
rm(projections_yahoo, projections_yahoo_placeholder, projections_yahoo_AuctionValue, projections_yahoo_AuctionValue_placeholder)
