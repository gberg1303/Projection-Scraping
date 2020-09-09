library(tidyverse)
library(boot)
library(simpleboot)
library(modelr)
library(DescTools)
library(progress)
library(janitor)
library(reshape)

### Load Data
Preseason_Combined_Projections <- Combined_Projections %>% 
  filter(Position == "QB" | Position == "RB" | Position == "WR" | Position == "TE") %>%
  filter(Individual.Fantasy.Points > 0)
Preseason_Projections <- Fantasy_Projections %>% 
  filter(Position == "QB" | Position == "RB" | Position == "WR" | Position == "TE") %>%
  filter(Fantasy.Points > 0)
Boot_Data <- rbind(
  Preseason_Combined_Projections %>%
    select(Player, Team, Position, Individual.Fantasy.Points) %>%
    dplyr::rename(Fantasy.Points = Individual.Fantasy.Points) %>%
    mutate(Type = "Original"),
  Preseason_Projections %>%
    select(Player, Team, Position, Ceiling.Fantasy.Points)%>%
    dplyr::rename(Fantasy.Points = Ceiling.Fantasy.Points) %>%
    mutate(Type = "Ceiling"),
  Preseason_Projections %>%
    select(Player, Team, Position, Floor.Fantasy.Points)%>%
    dplyr::rename(Fantasy.Points = Floor.Fantasy.Points) %>%
    mutate(Type = "Floor"),
  Preseason_Projections %>%
    select(Player, Team, Position, Ceiling.Fantasy.Points)%>%
    dplyr::rename(Fantasy.Points = Ceiling.Fantasy.Points) %>%
    mutate(Fantasy.Points = Fantasy.Points+Fantasy.Points*0.15) %>%
    mutate(Type = "Ceiling_Adjusted"),
  Preseason_Projections %>%
    select(Player, Team, Position, Floor.Fantasy.Points)%>%
    dplyr::rename(Fantasy.Points = Floor.Fantasy.Points) %>%
    mutate(Fantasy.Points = Fantasy.Points-Fantasy.Points*.50) %>%
    mutate(Type = "Floor_Adjusted"),
  Preseason_Projections %>%
    select(Player, Team, Position, Floor.Fantasy.Points) %>%
    dplyr::rename(Fantasy.Points = Floor.Fantasy.Points) %>%
    mutate(Fantasy.Points = Fantasy.Points-Fantasy.Points*.90) %>%
    mutate(Type = "Floor_Adjusted_2")
)


### Run the Loop of Bootstraps
Boot_Outcomes <- data.frame()
pb <- progress_bar$new(total = length((Boot_Data$Player %>% unique())))
for(i in (Boot_Data$Player %>% unique())){
  pb$tick()
test_boot <- Boot_Data %>%
  filter(Player == i) %>%
  select(Player, Team, Position, Fantasy.Points)

Boot_Means <- cbind.data.frame(as.character(test_boot$Player[1]), as.character(test_boot$Team[1]), as.character(test_boot$Position[1]), 
                               (one.boot(data = test_boot$Fantasy.Points, mean, R = 1000))$t
                               ) %>%
  mutate(Boot_ID = dplyr::row_number())
colnames(Boot_Means) <- c("Player", "Team", "Position", "Fantasy.Points", "Boot_ID")

Boot_Outcomes <- bind_rows(Boot_Outcomes, Boot_Means)
}
rm(i, pb)

### Get Rankings VoR and Percentages
Boot_Outcomes <- Boot_Outcomes %>%
  group_by(Boot_ID) %>%
  mutate(Points.Rank = order(Fantasy.Points, decreasing=TRUE)) %>%
  group_by(Boot_ID) %>%
  group_by(Position, add = TRUE) %>%
  mutate(Position.Rank = order(order(Fantasy.Points, decreasing=TRUE)))
  
### Set Replacements
source(paste0(getwd(), '/Value Over Replacement Settings.R'), echo=TRUE)

### Get the Value of the Replacement
qbValueOfReplacement <- mean(c(Boot_Outcomes$Fantasy.Points[which(Boot_Outcomes$Position == "QB" & Boot_Outcomes$Position.Rank == qbReplacements)], Boot_Outcomes$Fantasy.Points[which(Boot_Outcomes$Position == "QB" & Boot_Outcomes$Position.Rank == qbReplacements-1)], Boot_Outcomes$Fantasy.Points[which(Boot_Outcomes$Position == "QB" & Boot_Outcomes$Position.Rank == qbReplacements+1)]))
rbValueOfReplacement <- mean(c(Boot_Outcomes$Fantasy.Points[which(Boot_Outcomes$Position == "RB" & Boot_Outcomes$Position.Rank == rbReplacements)], Boot_Outcomes$Fantasy.Points[which(Boot_Outcomes$Position == "RB" & Boot_Outcomes$Position.Rank == rbReplacements-1)], Boot_Outcomes$Fantasy.Points[which(Boot_Outcomes$Position == "RB" & Boot_Outcomes$Position.Rank == rbReplacements+1)]))
wrValueOfReplacement <- mean(c(Boot_Outcomes$Fantasy.Points[which(Boot_Outcomes$Position == "WR" & Boot_Outcomes$Position.Rank == wrReplacements)], Boot_Outcomes$Fantasy.Points[which(Boot_Outcomes$Position == "WR" & Boot_Outcomes$Position.Rank == wrReplacements-1)], Boot_Outcomes$Fantasy.Points[which(Boot_Outcomes$Position == "WR" & Boot_Outcomes$Position.Rank == wrReplacements+1)]))
teValueOfReplacement <- mean(c(Boot_Outcomes$Fantasy.Points[which(Boot_Outcomes$Position == "TE" & Boot_Outcomes$Position.Rank == teReplacements)], Boot_Outcomes$Fantasy.Points[which(Boot_Outcomes$Position == "TE" & Boot_Outcomes$Position.Rank == teReplacements-1)], Boot_Outcomes$Fantasy.Points[which(Boot_Outcomes$Position == "TE" & Boot_Outcomes$Position.Rank == teReplacements+1)]))

### Get each player's VOR
library(data.table)
Boot_Outcomes$VoR <- 0
Boot_Outcomes <- as.data.table(Boot_Outcomes)
Boot_Outcomes[which(Position == "QB"), VoR := Fantasy.Points - qbValueOfReplacement]
Boot_Outcomes[which(Position == "RB"), VoR := Fantasy.Points - rbValueOfReplacement]
Boot_Outcomes[which(Position == "WR"), VoR := Fantasy.Points - wrValueOfReplacement]
Boot_Outcomes[which(Position == "TE"), VoR := Fantasy.Points - teValueOfReplacement]

### Remove Extras
rm(test, dstReplacements, dstValueOfReplacement, kReplacements, kValueOfReplacement, qbReplacements, qbValueOfReplacement, rbReplacements, rbValueOfReplacement, teReplacements, teValueOfReplacement, wrReplacements, wrValueOfReplacement)

### Add VoR Rank and VoR Position Rank
Boot_Outcomes <- Boot_Outcomes %>%
  group_by(Boot_ID) %>%
  mutate(VoR.Rank = order(order(VoR, decreasing=TRUE))) %>%
  group_by(Boot_ID) %>%
  group_by(Position, add = TRUE) %>%
  mutate(VoR.Position.Rank = order(order(VoR, decreasing=TRUE)))

### Summarise to get the results of the simulation

## Bucket
Player_Predictions_Bucket <- Boot_Outcomes %>%
  group_by(Player, Team, Position) %>%
  summarise(
    Points.Position.1.5 = mean(Position.Rank <= 5),
    Points.Position.6.10 = mean(Position.Rank <= 10 & Position.Rank > 5),
    Points.Position.11.15 = mean(Position.Rank <= 15 & Position.Rank > 10),
    Points.Position.16.20 = mean(Position.Rank <= 20 & Position.Rank > 15),
    Points.Position.21.25 = mean(Position.Rank <= 25 & Position.Rank > 20),
    Points.Position.26.30 = mean(Position.Rank <= 30 & Position.Rank > 25),
    Points.Position.31.35 = mean(Position.Rank <=35 & Position.Rank > 30),
    Points.Position.36.40 = mean(Position.Rank <= 40 & Position.Rank > 35),
    Points.Position.Above.40 = mean(Position.Rank > 40 & Position.Rank > 40),
    VoR.Top.1.5 = mean(VoR.Rank <= 5),
    VoR.Top.6.10 = mean(VoR.Rank <= 10 & Position.Rank > 5),
    VoR.Top.11.15 = mean(VoR.Rank <= 15 & Position.Rank > 10),
    VoR.Top.16.20 = mean(VoR.Rank <= 20 & Position.Rank > 15),
    VoR.Top.21.25 = mean(VoR.Rank <= 25 & Position.Rank > 20),
    VoR.Top.26.30 = mean(VoR.Rank <= 30 & Position.Rank > 25),
    VoR.Top.31.35 = mean(VoR.Rank <=35 & Position.Rank > 30),
    VoR.Top.36.40 = mean(VoR.Rank <= 40 & Position.Rank > 35),
    VoR.Top.Above.40 = mean(VoR.Rank > 40)
  )

# Inclusive
Player_Predictions_Inclusive <- Boot_Outcomes %>%
  group_by(Player, Team, Position) %>%
  summarise(
    Points.Position.Top.Five = mean(Position.Rank <= 5),
    Points.Position.Top.Ten = mean(Position.Rank <= 10),
    Points.Position.Top.Fifteen = mean(Position.Rank <= 15),
    Points.Position.Top.Twenty = mean(Position.Rank <= 20),
    Points.Position.Top.Twentyfive = mean(Position.Rank <= 25),
    Points.Position.Top.Thirty = mean(Position.Rank <= 30),
    Points.Position.Top.Thirtyfive = mean(Position.Rank <=35),
    Points.Position.Top.Fourty = mean(Position.Rank <= 40),
    Points.Position.Top.Else = mean(Position.Rank > 40),
    VoR.Top.Five = mean(VoR.Rank <= 5),
    VoR.Top.Ten = mean(VoR.Rank <= 10),
    VoR.Top.Fifteen = mean(VoR.Rank <= 15),
    VoR.Top.Twenty = mean(VoR.Rank <= 20),
    VoR.Top.Twentyfive = mean(VoR.Rank <= 25),
    VoR.Top.Thirty = mean(VoR.Rank <= 30),
    VoR.Top.Thirtyfive = mean(VoR.Rank <=35),
    VoR.Top.Fourty = mean(VoR.Rank <= 40),
    VoR.Top.Else = mean(VoR.Rank > 40)
  )

Player_Predictions_Test <- merge(
  x = Player_Predictions_Inclusive,
  y = Player_Predictions_Bucket,
  by = c("Player", "Team", "Position")
) %>%
  dplyr::select(Player, Team, Position, everything())

####################################################################################################################################################################################
####################################################################################################################################################################################
### Add Historical Baselines
####################################################################################################################################################################################
####################################################################################################################################################################################

# Load the Data
Historical_Projection_Baselines <- read_csv("/Users/jonathangoldberg/Google Drive/Random/Sports/Fantasy Football/Projection Scraping/Dependent Files/Historical_Projection_Baselines.csv")
Player_Predictions <- Player_Predictions_Test

Player_Predictions <- Player_Predictions %>%
  merge(x = ., y = Preseason_Projections %>% select(Player, Team, Position, Position.Rank), by = c("Player", "Team", "Position"), all.x = TRUE) %>%
  reshape2::melt(id.vars = c("Player", "Team", "Position", "Position.Rank")) %>%
  dplyr::rename(Projection_Type = variable,
                Projection = value) %>%
  mutate(Inclusive_Bucket = ifelse(str_detect(Projection_Type, "Top") & str_detect(Projection_Type, "Position") == TRUE, "Inclusive", "Bucket")) %>%
  mutate(Projection_Rank = ifelse(Position.Rank %in% 1:5 & Inclusive_Bucket == "Bucket", "Projected 1-5",
                                  ifelse(Position.Rank %in% 6:10 & Inclusive_Bucket == "Bucket", "Projected 6-10",
                                         ifelse(Position.Rank %in% 11:15 & Inclusive_Bucket == "Bucket", "Projected 11-15", 
                                                ifelse(Position.Rank %in% 16:20 & Inclusive_Bucket == "Bucket", "Projected 16-20", 
                                                       ifelse(Position.Rank %in% 21:25 & Inclusive_Bucket == "Bucket", "Projected 21-25", 
                                                              ifelse(Position.Rank %in% 26:30 & Inclusive_Bucket == "Bucket", "Projected 26-30", 
                                                                     ifelse(Position.Rank %in% 31:35 & Inclusive_Bucket == "Bucket", "Projected 31-35", 
                                                                            ifelse(Position.Rank %in% 36:40 & Inclusive_Bucket == "Bucket", "Projected 36-40", 
                                                                                   ifelse(Position.Rank %in% 1:5 & Inclusive_Bucket == "Inclusive", "Projected Top 5",
                                                                                          ifelse(Position.Rank %in% 1:10 & Inclusive_Bucket == "Inclusive", "Projected Top 10",
                                                                                                 ifelse(Position.Rank %in% 1:15 & Inclusive_Bucket == "Inclusive", "Projected Top 15", 
                                                                                                        ifelse(Position.Rank %in% 1:20 & Inclusive_Bucket == "Inclusive", "Projected Top 20", 
                                                                                                               ifelse(Position.Rank %in% 1:25 & Inclusive_Bucket == "Inclusive", "Projected Top 25", 
                                                                                                                      ifelse(Position.Rank %in% 1:30 & Inclusive_Bucket == "Inclusive", "Projected Top 30", 
                                                                                                                             ifelse(Position.Rank %in% 1:35 & Inclusive_Bucket == "Inclusive", "Projected Top 35", 
                                                                                                                                    ifelse(Position.Rank %in% 1:40 & Inclusive_Bucket == "Inclusive", "Projected Top 40", "Projected Above 40"))))))))))))))))) %>%
  mutate(Projection_Type = gsub("Points.Position.Top.Five", "Finished.Top.5", Projection_Type),
         Projection_Type = gsub("Points.Position.Top.Ten", "Finished.Top.10", Projection_Type),
         Projection_Type = gsub("Points.Position.Top.Fifteen", "Finished.Top.15", Projection_Type),
         Projection_Type = gsub("Points.Position.Top.Twentyfive", "Finished.Top.25", Projection_Type),
         Projection_Type = gsub("Points.Position.Top.Twenty", "Finished.Top.20", Projection_Type),
         Projection_Type = gsub("Points.Position.Top.Thirtyfive", "Finished.Top.35", Projection_Type),
         Projection_Type = gsub("Points.Position.Top.Thirty", "Finished.Top.30", Projection_Type),
         Projection_Type = gsub("Points.Position.Top.Fourty", "Finished.Top.40", Projection_Type),
         Projection_Type = gsub("Points.Position.Top.Else", "Finished.Above.40", Projection_Type),
         
         Projection_Type = gsub("Points.Position.1.5", "Finished.1.5", Projection_Type),
         Projection_Type = gsub("Points.Position.6.10", "Finished.6.10", Projection_Type),
         Projection_Type = gsub("Points.Position.11.15", "Finished.11.15", Projection_Type),
         Projection_Type = gsub("Points.Position.16.20", "Finished.16.20", Projection_Type),
         Projection_Type = gsub("Points.Position.21.25", "Finished.21.25", Projection_Type),
         Projection_Type = gsub("Points.Position.26.30", "Finished.26.30", Projection_Type),
         Projection_Type = gsub("Points.Position.31.35", "Finished.31.35", Projection_Type),
         Projection_Type = gsub("Points.Position.36.40", "Finished.36.40", Projection_Type),
         Projection_Type = gsub("Points.Position.Above.40", "Finished.Above.40", Projection_Type)
         ) %>%
  filter(str_detect(Projection_Type, "VoR") != TRUE) %>%
  filter(str_detect(Projection_Type, "Result") != TRUE) %>%
  merge(x=., y = Historical_Projection_Baselines, by.x = c("Position", "Projection_Rank", "Projection_Type", "Inclusive_Bucket"), by.y = c("Position", "Projection", "Actual", "Inclusive_Bucket"), all.x = TRUE) %>%
  mutate(Projection = Projection*0.65 + Conversion_Rate*0.35) %>%
  select(Player, Team, Position, Projection_Type, Projection) %>%
  unique() %>%
  reshape2::dcast(Player + Team + Position ~ Projection_Type, value.var="Projection") %>%
  merge(x = ., y = Preseason_Projections %>% select(Player, Team, Risk, Position, Average.Draft.Position, Average.Auction.Value, Cost, Bye, Position.Rank, Tier, Dropoff, Opportunities, Touches, VoR), by = c("Player", "Team", "Position"), all.x = TRUE) %>%
  mutate(Bin = case_when(
    Position.Rank %in% 1:12 & Position == "WR" | Position.Rank %in% 1:12 & Position ==  "RB" ~ "1:12",
    Position.Rank %in% 1:5 & Position == "QB" | Position.Rank %in% 1:5 & Position ==  "TE" ~ "1:12",
    Position.Rank %in% 13:14 ~ "13:14",
    Position.Rank %in% 15:15 ~ "15:15",
    Position.Rank %in% 16:20 ~ "16:20",
    Position.Rank %in% 21:25 ~ "21:25",
    Position.Rank %in% 26:30 ~ "26:30",
    Position.Rank %in% 31:35 ~ "31:35",
    Position.Rank %in% 36:40 ~ "36:40",
    Position.Rank %in% 41:20000 ~ "41:20000",
  )) %>%
  group_by(Position, Bin) %>%
  mutate(boom.vor = mean(VoR, na.rm = TRUE)) %>%
  ungroup() %>%
  group_by(Position) %>%
  mutate(boom.vor = max(boom.vor)) %>%
  ungroup() %>%
  mutate(Expected.Boom.VoR = ifelse(Position == "WR" | Position ==  "RB", boom.vor*(Finished.Top.15+Finished.Top.10)/2, boom.vor*(Finished.Top.5))) %>%
  select(Player, Team, Position, Average.Draft.Position, Average.Auction.Value, Cost, Bye, Position.Rank, Tier, Dropoff, Opportunities, Touches, VoR, Expected.Boom.VoR,
         Finished.Top.5, Finished.Top.10, Finished.Top.15, Finished.Top.20, Finished.Top.25, Finished.Top.30, Finished.Top.35, Finished.Top.40,
         Finished.1.5, Finished.6.10, Finished.11.15, Finished.16.20, Finished.21.25, Finished.26.30, Finished.31.35, Finished.36.40, Finished.Above.40, Risk) %>%
  mutate_if(is.numeric, round, 2)


#### Remove everything
rm(Historical_Projection_Baselines, Player_Season_Data, Player_Predictions_Test, Player_Predictions_Bucket, Player_Predictions_Inclusive, 
Boot_Outcomes, Boot_Means, Boot_Data, Historical_Football_Statistics, Preseason_Projections, Preseason_Combined_Projections, test_boot)






