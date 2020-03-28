library(dplyr)
#Remove Players Here: This is the ID number that can remove the players and rows from consideration. Change the row number to remove
#the desired player from the database.
#The trainbackup puts the dataset into a seperate storage in case you remove someone you did not meant to. I'd recommend backing up everytime you remove 5 people
#{trainbackup <- train
#train <- filter(train, train$id!="Insert Player ID Here")
#} -16033, Ravens, 3046779 - Goff, 3916387 - Lamar

## How to select your picks --- ad the player ID and run the entire thing
## DO NOT Change PICK 0, this is a necessary placeholder
{Pick0 <- filter(train, train$id=="1234567")
Pick1 <- filter(train, train$id=="-16033") # Ravens
Pick2 <- filter(train, train$id=="3916387") # Lamar
Pick3 <- filter(train, train$id=="")
Pick4 <- filter(train, train$id=="")
Pick5 <- filter(train, train$id=="")
Pick6 <- filter(train, train$id=="")
Pick7 <- filter(train, train$id=="Insert Player ID")
Pick8 <- filter(train, train$id=="Insert Player ID")
Pick9 <- filter(train, train$id=="Insert Player ID")
Pick10 <- filter(train, train$id=="Insert Player ID")
Pick11 <- filter(train, train$id=="Insert Player ID")
Pick12 <- filter(train, train$id=="Insert Player ID")
Pick13 <- filter(train, train$id=="Insert Player ID")
Pick14 <- filter(train, train$id=="Insert Player ID")
Pick15 <- filter(train, train$id=="Insert Player ID")
Pick16 <- filter(train, train$id=="Insert Player ID")
Pick17 <- filter(train, train$id=="Insert Player ID")
setplayers <- rbind(Pick0, Pick1, Pick2, Pick3, Pick4, Pick5, Pick6, Pick7, Pick8, Pick9, Pick10, Pick11,
                        Pick12, Pick13, Pick14, Pick15, Pick17)
}

#Use this only if fucked up and removed someone you did not mean to. This will restore the dataset from the backup
# train <- trainbackup

## Change the cost of the pick to what was used to buy him
#train[Row Number,11] = Cost
