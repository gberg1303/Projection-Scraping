library(tidyverse)
library(XML)
library(RCurl)
library(gtools)
library(stringr)
library(httr)

### Set Up The Conditionals for the Large Scrape
if(week == 0){week_type <- paste("season")}
if(week == 0){week_no <- 1}
if(week > 0){week_type <- paste("week")}
if(week > 0){week_no <- paste(week)}

### Set up the Original Table
nfl_proj_url <- GET(paste0("https://fantasy.nfl.com/research/projections?offset=1&position=O&sort=projectedPts&statCategory=projectedStats&statSeason=", season, "&statType=", week_type, "ProjectedStats&statWeek=", week_no))
nfl_proj <- readHTMLTable(htmlParse(nfl_proj_url), stringsAsFactors = FALSE)$`NULL`
if(week == 0){colnames(nfl_proj) <- c("Player", "Opponent", "Games.Played", "Passing.Yards", "Passing.Touchdowns", "Interceptions", "Rushing.Yards", "Rushing.Touchdowns", "Receptions", "Receiving.Yards", 
              "Receiving.Touchdowns", "Return.Touchdowns","Fumbles.Touchdown", "2PT.Conversion", "Fumbles.Lost", "Fantasy.Points")}
if(week > 0){colnames(nfl_proj) <- c("Player", "Opponent", "Passing.Yards", "Passing.Touchdowns", "Interceptions", "Rushing.Yards", "Rushing.Touchdowns", "Receptions", "Receiving.Yards", 
                                     "Receiving.Touchdowns", "Return.Touchdowns","Fumbles.Touchdown", "2PT.Conversion", "Fumbles.Lost", "Fantasy.Points")}

### Scrape the rest and add it
pages <- c(26, 51, 76, 101, 126, 151, 176, 201, 226, 251, 276, 301, 326, 351, 376, 401, 426, 451, 476, 501, 526, 551, 576, 601, 626, 651, 676, 701, 726, 751, 776)
for(pages in pages){
nfl_proj_url <- getURL(paste0("https://fantasy.nfl.com/research/projections?offset=", pages, "&position=O&sort=projectedPts&statCategory=projectedStats&statSeason=", season, "&statType=", week_type, "ProjectedStats&statWeek=", week_no))
nfl_proj_placeholder <- readHTMLTable(nfl_proj_url, stringsAsFactors = FALSE)$`NULL`
if(week == 0){colnames(nfl_proj_placeholder) <- c("Player", "Opponent", "Games.Played", "Passing.Yards", "Passing.Touchdowns", "Interceptions", "Rushing.Yards", "Rushing.Touchdowns", "Receptions", "Receiving.Yards", 
                                      "Receiving.Touchdowns", "Return.Touchdowns","Fumbles.Touchdown", "2PT.Conversion", "Fumbles.Lost", "Fantasy.Points")}
if(week > 0){colnames(nfl_proj_placeholder) <- c("Player", "Opponent", "Passing.Yards", "Passing.Touchdowns", "Interceptions", "Rushing.Yards", "Rushing.Touchdowns", "Receptions", "Receiving.Yards", 
                                     "Receiving.Touchdowns", "Return.Touchdowns","Fumbles.Touchdown", "2PT.Conversion", "Fumbles.Lost", "Fantasy.Points")}
nfl_proj <- smartbind(nfl_proj, nfl_proj_placeholder)
}

### Get Kickers
pages <- c(1, 26)
for(pages in pages){
nfl_proj_url <- getURL(paste0("https://fantasy.nfl.com/research/projections?offset=", pages, "&position=7&sort=projectedPts&statCategory=projectedStats&statSeason=", season, "&statType=", week_type, "ProjectedStats&statWeek=", week_no))
nfl_proj_placeholder <- readHTMLTable(nfl_proj_url, stringsAsFactors = FALSE)$`NULL`
if(week == 0){colnames(nfl_proj_placeholder) <- c("Player", "Opponent", "Games.Played", "FGM.XP", "FGM.1_19", "FGM.20_29", "FGM.30_39", "FGM.40_49", "FGM.50.", "Fantasy.Points")}
if(week > 0){colnames(nfl_proj_placeholder) <- c("Player", "Opponent", "FGM.XP", "FGM.1_19", "FGM.20_29", "FGM.30_39", "FGM.40_49", "FGM.50.", "Fantasy.Points")}
nfl_proj <- smartbind(nfl_proj, nfl_proj_placeholder)}


### Remove Funky Characters
nfl_proj$Player <- str_replace_all(nfl_proj$Player, " III ", " ")
nfl_proj$Player <- str_replace_all(nfl_proj$Player, " II ", " ")
nfl_proj$Player <- str_replace_all(nfl_proj$Player, " Jr.", "")
nfl_proj$Player <- str_replace_all(nfl_proj$Player, " Sr.", "")
nfl_proj$Player <- str_replace_all(nfl_proj$Player, " IV ", " ")
nfl_proj$Player <- str_replace_all(nfl_proj$Player, " V ", " ")
nfl_proj$Player <- str_replace_all(nfl_proj$Player, " D. ", " ")

### Remove Periods from Name
nfl_proj$Player <- str_replace_all(nfl_proj$Player, "St. ", "St")
nfl_proj$Player <- str_replace_all(nfl_proj$Player, "\\. ", " ")
nfl_proj$Player <- str_replace_all(nfl_proj$Player, "\\.", "")

### Extract Team
nfl_proj$Player <- sub("^\\s*(\\S+\\s+\\S+\\s+\\S+\\s+\\S+\\s+\\S+).*", "\\1", nfl_proj$Player) ## Clear everything after the Fifth
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
nfl_proj$Team <- str_trim(substrRight(nfl_proj$Player, 3))

### Extract Position
nfl_proj$Player <- sub("^\\s*(\\S+\\s+\\S+\\s+\\S+).*", "\\1", nfl_proj$Player) ## Clear everything after the Third
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
nfl_proj$Position <- str_trim(substrRight(nfl_proj$Player, 2))

### Clean Names One Last Time
nfl_proj$Player <- sub("^\\s*(\\S+\\s+\\S+).*", "\\1", nfl_proj$Player) ## Clear everything after the Second
nfl_proj$Player <- trimws(nfl_proj$Player)

### Chaange Team Names
nfl_proj$Team[nfl_proj$Team == "JAX"] <- "JAC"
nfl_proj$Team[nfl_proj$Team == "LA"] <- "LAR"

### Rearrange Projecitons and Finalize
NFL_Projections <- nfl_proj %>%
  select(-Opponent, -Fantasy.Points) %>% 
  mutate(Platform = "NFL") %>%
  select(Platform, Player, Team, Position, everything())
if(week == 0){NFL_Projections[,5:23] <- as.numeric(unlist(NFL_Projections[,5:23]))}
if(week > 0){NFL_Projections[,5:22] <- as.numeric(unlist(NFL_Projections[,5:22]))}

### End Draft Scraping
rm(pages, nfl_proj, nfl_proj_placeholder, nfl_proj_url)
