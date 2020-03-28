###
# By Jonathan Goldberg (Gberg1303)
# Use the VOR and League Scoring Documents to set up the information for your league! 
###

### Set Working Directory in case of different folder
setwd()

### Load the Functions
source(paste0(getwd(), '/Projections_Main.R'))

### Run the Function: Fantasy_Football_Projections(): Week = 0 implies the draft
Fantasy_Football_Projections(sources = c("CBS", "ESPN", "FantasySharks", "Sleeper", "Yahoo", "FantasyPros", "NFL"), Week = 4, Season = 2019, Scoring = "PPR", VOR = "Standard", MaxBid = FALSE, Keep.Platform.Projections = TRUE, Proper.Floors = TRUE)

### Be Careful to save in correct folder 
print("Be Careful to save in correct folder")

### Save for Easy Load
write_csv(Fantasy_Projections, "Fantasy Projections 2019.csv")

### Save for Posterity
write_csv(Fantasy_Projections, "Fantasy Season Projections 2019.csv")
