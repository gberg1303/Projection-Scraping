#### Thanks to Isaac Peterson for the loop!

#Library
library(lpSolveAPI)

### Set Working Directory in case of different folder
setwd("/Users/jonathangoldberg/Google Drive/Random/Sports/Fantasy Football/Projection Scraping")

#Subset data
Average_Fantasy_Projections <- data.frame(Average_Fantasy_Projections)
train <- Average_Fantasy_Projections[c("id", "Player", "Position", "Bye", "Average.Fantasy.Points", "Risk", "VoR", "Average.Auction.Value", "Cost", "Floor.Fantasy.Points", "Dropoff")]
train <- data.table(train)
train[which(train$Cost == 0), Cost := 1]
train$dk_total <- 1
placeholder <- data.frame(1234567, "placeholder", "PLC", 0, 0,0,0,0,0,0,0,1)
colnames(placeholder) <- colnames(train)
train <- rbind(train, placeholder)
train <- train %>% arrange(desc(Average.Fantasy.Points))
find_teams(train, 190, constraint = c("none"), league = c("Jonathan"), setPlayers =  NULL)$Player

### Bid Up To
numTotalStarters <- 10

#Bid Up To
listOfPlayers <- vector(mode="character", length=numTotalStarters)
bidUpTo <- vector(mode="numeric", length=length(train$Player))
newCost <- train$Cost

pb <- txtProgressBar(min = 0, max = length(250), style = 3)
for(i in 1:250){
  if(train$Player[i] == "placeholder"){break()}
  setTxtProgressBar(pb, i)
  j <- 1
  listOfPlayers <- rep(train$Player[i],numTotalStarters)
  newCost <- train$Cost
  while(!is.na(match(train$Player[i],listOfPlayers))){
    newCost[i] <- j
    train$Cost <- newCost
    listOfPlayers <- find_teams(train, 190, constraint = c("none"), league = c("Jonathan"), setPlayers =  NULL)$Player  #UPDATE: maxrisk
    bidUpTo[i] <- j
    j <- j+1
  }
}

### Rename Column and Merge them over
train <- train %>% filter(Player != "placeholder")
colnames(train)[9] <- c("Max.Bid")
train <- train[c("Player", "Max.Bid")]
Average_Fantasy_Projections <- data.table(Average_Fantasy_Projections)
Average_Fantasy_Projections[which(Average_Fantasy_Projections$Cost == 0), Cost := 1]
Average_Fantasy_Projections$Fantasy.Points <- as.numeric(Average_Fantasy_Projections$Average.Fantasy.Points)
Average_Fantasy_Projections <- Average_Fantasy_Projections %>% arrange(desc(Average.Fantasy.Points))
Average_Fantasy_Projections$Max.Bid <- train$Max.Bid

### Remove extras
rm(pb, listOfPlayers, bidUpTo, newCost, numTotalPlayers, numTotalStarters, train)
rm(find_teams, placeholder, Pick0, Pick1, Pick2, Pick3, Pick4, Pick5, Pick6, Pick7, Pick8, Pick9, Pick10, Pick11,
   Pick12, Pick13, Pick14, Pick15, Pick16, Pick17, setplayers, j)

