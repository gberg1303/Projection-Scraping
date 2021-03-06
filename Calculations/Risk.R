library(tidyverse)
library(RCurl)
library(XML)
library(stringr)
library(simpleboot)
library(boot)

### Get Risk Rankings from Fantasy Pros
if(week == 0){
rankings_fp <- getURL("https://www.fantasypros.com/nfl/rankings/ppr-cheatsheets.php#")
rankings_fp <- readHTMLTable(rankings_fp, stringsAsFactors = FALSE)$`rank-data`
rankings_fp <- rankings_fp %>%
  filter(is.na(V3) != TRUE) %>%
  filter(is.na(V9) != TRUE) %>%
  select(V3, V9) %>%
  dplyr::rename(Player = V3,
         Risk = V9) %>%
  mutate(Risk = as.numeric(Risk))
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
rankings_fp$Team <- str_trim(substrRight(rankings_fp$Player, 3))
rankings_fp$Player <- gsub("[.]","",rankings_fp$Player) 
rankings_fp$Player <- str_replace_all(rankings_fp$Player, " III", "")
rankings_fp$Player <- str_replace_all(rankings_fp$Player, " II", "")
rankings_fp$Player <- str_replace_all(rankings_fp$Player, " Jr", "")
rankings_fp$Player <- str_replace_all(rankings_fp$Player, " Sr", "")
rankings_fp$Player <- str_replace_all(rankings_fp$Player, " IV", "")
rankings_fp$Player <- str_replace_all(rankings_fp$Player, " V", "")
rankings_fp$Player <- sub("^\\s*(\\S+\\s+\\S+).*", "\\1", rankings_fp$Player) ## Clear everything after the second space 
rankings_fp$Player <- substr(rankings_fp$Player, 1, nchar(rankings_fp$Player)-1) 
rankings_fp$Player <- trimws(rankings_fp$Player)

### Change Names
rankings_fp <- as.data.table(rankings_fp)
rankings_fp[which(rankings_fp$Player == "Mitch Trubisky"), Player := "Mitchell Trubisky"]
rankings_fp[which(rankings_fp$Player == "Odell Beckha"), Player := "Odell Beckham"]

### Scale the Risk to Something more understandable
rankings_fp$Risk <- scale(rankings_fp$Risk)
rankings_fp$Risk <- ((rankings_fp$Risk*2)/sd(rankings_fp$Risk, na.rm = TRUE)) + (5-mean(rankings_fp$Risk, na.rm = TRUE))
}

### Get Expert Rankings
if(week > 0){
  rankings_fp <- getURL("https://www.fantasypros.com/nfl/rankings/ppr-flex.php")
  rankings_fp <- readHTMLTable(rankings_fp, stringsAsFactors = FALSE)$`rank-data`
  rankings_fp <- rankings_fp %>%
    filter(is.na(V3) != TRUE) %>%
    filter(is.na(V9) != TRUE) %>%
    select(V3, V9) %>%
    rename(Player = V3,
           Risk = V9) %>%
    mutate(Risk = as.numeric(Risk))
  substrRight <- function(x, n){
    substr(x, nchar(x)-n+1, nchar(x))
  }
  rankings_fp$Team <- str_trim(substrRight(rankings_fp$Player, 3))
  rankings_fp$Player <- gsub("[.]","",rankings_fp$Player) 
  rankings_fp$Player <- str_replace_all(rankings_fp$Player, " III", "")
  rankings_fp$Player <- str_replace_all(rankings_fp$Player, " II", "")
  rankings_fp$Player <- str_replace_all(rankings_fp$Player, " Jr", "")
  rankings_fp$Player <- str_replace_all(rankings_fp$Player, " Sr", "")
  rankings_fp$Player <- str_replace_all(rankings_fp$Player, " IV", "")
  rankings_fp$Player <- str_replace_all(rankings_fp$Player, " V", "")
  rankings_fp$Player <- sub("^\\s*(\\S+\\s+\\S+).*", "\\1", rankings_fp$Player) ## Clear everything after the second space 
  rankings_fp$Player <- substr(rankings_fp$Player, 1, nchar(rankings_fp$Player)-1) 
  rankings_fp$Player <- trimws(rankings_fp$Player)
  
  ### Change Names
  rankings_fp <- as.data.table(rankings_fp)
  rankings_fp[which(rankings_fp$Player == "Mitch Trubisky"), Player := "Mitchell Trubisky"]
  rankings_fp[which(rankings_fp$Player == "Odell Beckha"), Player := "Odell Beckham"]
  
  ### Scale the Risk to Something more understandable
  rankings_fp$Risk <- scale(rankings_fp$Risk)
  rankings_fp$Risk <- ((rankings_fp$Risk*2)/sd(rankings_fp$Risk, na.rm = TRUE)) + (5-mean(rankings_fp$Risk, na.rm = TRUE))
}


### Get the Risk via standard deviation
Risk <- Combined_Projections %>%
  group_by(Player) %>%
  group_by(Team, add = TRUE) %>%
  group_by(Position, add = TRUE) %>%
  summarise(Risk = sd(Individual.Fantasy.Points, na.rm = TRUE),
            Average.Fantasy.Points = mean(Individual.Fantasy.Points, na.rm = TRUE),
            Ceiling.Fantasy.Points = (Average.Fantasy.Points+(Risk*2)),
            Floor.Fantasy.Points = (Average.Fantasy.Points-(Risk*2)))

### Scale the Risk to Something more understandable
Risk$Risk <- scale(Risk$Risk)
Risk$Risk <- ((Risk$Risk*2)/sd(Risk$Risk, na.rm = TRUE)) + (5-mean(Risk$Risk, na.rm = TRUE))

### Merge the Risks
Risk <- merge(Risk, rankings_fp, by = c("Player", "Team"), all.x = TRUE, all.y = FALSE)

### Make Numerics
Risk$Risk.x <- as.numeric(Risk$Risk.x)
Risk$Risk.y <- as.numeric(Risk$Risk.y)

### Average the Risks
Risk <- Risk %>% 
  group_by(Player) %>%
  group_by(Team, add = TRUE) %>%
  group_by(Position, add = TRUE) %>%
  mutate(Risk = (((Risk.x*.4 + Risk.y*.6)/2)))

### Move Risk data over to NAs
Risk <- as.data.table(Risk)
Risk[which(is.na(Risk) == TRUE), Risk := Risk.x]


### Scale the Risk to Something more understandable
Risk$Risk <- scale(Risk$Risk)
Risk$Risk <- ((Risk$Risk*2)/sd(Risk$Risk, na.rm = TRUE)) + (5-mean(Risk$Risk, na.rm = TRUE))


### Separate to Cbind
Ceiling.Fantasy.Points <- Risk$Ceiling.Fantasy.Points
Floor.Fantasy.Points <- Risk$Floor.Fantasy.Points
Risk <- Risk$Risk

### Merge Back Together
Average_Fantasy_Projections <- cbind.data.frame(Average_Fantasy_Projections, Ceiling.Fantasy.Points)
Average_Fantasy_Projections <- cbind.data.frame(Average_Fantasy_Projections, Floor.Fantasy.Points)
Average_Fantasy_Projections <- cbind.data.frame(Average_Fantasy_Projections, Risk)

### For assymetric Floor and Ceilings. More accurate but takes more time:
if(Proper.Floors == TRUE){

# Reset and get player names/id
players <- paste(Average_Fantasy_Projections$Player, Average_Fantasy_Projections$Position, Average_Fantasy_Projections$Team)
rm(Risk_Ceiling.Floor)

# Run the loop for Proper Floors
for(player in players){
  Confidence_Intervals <- Combined_Projections %>%
    filter(paste(Player, Position, Team) == paste(player))
   if(nrow(Confidence_Intervals) < 2){
    Ceiling.Fantasy.Points <- as.numeric(NA)
    Floor.Fantasy.Points <- as.numeric(NA)
  }
  if(nrow(Confidence_Intervals) >= 2 & sum(Confidence_Intervals$Individual.Fantasy.Points) > 0 & mean(Confidence_Intervals$Individual.Fantasy.Points) != Confidence_Intervals$Individual.Fantasy.Points[1]){
    Floor.Fantasy.Points <- boot.ci(one.boot(Confidence_Intervals$Individual.Fantasy.Points, mean, R = 1000), type=c("perc", "bca"), conf = .99)[["bca"]][4]
    Ceiling.Fantasy.Points <- boot.ci(one.boot(Confidence_Intervals$Individual.Fantasy.Points, mean, R = 1000), type=c("perc", "bca"), conf = .99)[["bca"]][5]
  }
  if(sum(Confidence_Intervals$Individual.Fantasy.Points) == 0){
    Ceiling.Fantasy.Points <- as.numeric(NA)
    Floor.Fantasy.Points <- as.numeric(NA)
  }
  if(Confidence_Intervals$Individual.Fantasy.Points[1] == mean(Confidence_Intervals$Individual.Fantasy.Points)){
    Ceiling.Fantasy.Points <- as.numeric(NA)
    Floor.Fantasy.Points <- as.numeric(NA)
  }
  Ceiling.Floor <- cbind(Ceiling.Fantasy.Points, Floor.Fantasy.Points)
  ifelse(exists("Risk_Ceiling.Floor") == TRUE, assign("Risk_Ceiling.Floor", rbind.data.frame(Risk_Ceiling.Floor, Ceiling.Floor)), assign("Risk_Ceiling.Floor", Ceiling.Floor))
  print(player)
}

### Remove Files and Change the Floors Again
Average_Fantasy_Projections$Floor.Fantasy.Points <- Risk_Ceiling.Floor$Floor.Fantasy.Points
Average_Fantasy_Projections$Ceiling.Fantasy.Points <- Risk_Ceiling.Floor$Ceiling.Fantasy.Points
rm(Ceiling.Fantasy.Points, Floor.Fantasy.Points, Ceiling.Floor, Confidence_Intervals, player, players)
}


### Remove Uneeded Items
rm(Risk, High.Fantasy.Points, Low.Fantasy.Points, Ceiling.Fantasy.Points, Floor.Fantasy.Points, remove, rankings_fp, substrRight, Risk_Ceiling.Floor)
