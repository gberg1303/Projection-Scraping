### Fix NA Fantasy Point Errors
Average_Fantasy_Projections <- as.data.table(Average_Fantasy_Projections)
Average_Fantasy_Projections[which(Average.Fantasy.Points > Ceiling.Fantasy.Points), Average.Fantasy.Points := (Ceiling.Fantasy.Points + Floor.Fantasy.Points)/2]
Average_Fantasy_Projections[which(Average.Fantasy.Points > Ceiling.Fantasy.Points), VoR := (Ceiling.VoR + Floor.VoR)/2]


### Drop Unimportant Columns and Add Some Other Better Metrics
Fantasy_Projections <- Average_Fantasy_Projections
Fantasy_Projections[is.na(Fantasy_Projections)] <- 0
Fantasy_Projections <- as.data.table(Fantasy_Projections)
ifelse(MaxBid == TRUE,
  Fantasy_Projections <- Fantasy_Projections %>%
    mutate(Opportunities = (Pass.Attempts + Carries + Targets), 
           Touches = Carries + Receptions,
           Value.Per.Opportunity = (VoR/Opportunities), 
           Fantasy.Points = Average.Fantasy.Points) %>%
    select(id, Player, Team, Position, Bye, Average.Auction.Value, Cost, Max.Bid, Average.Draft.Position, Games.Played, Opportunities, Touches, Tier, Value.Rank, VoR, Ceiling.VoR, Floor.VoR, Dropoff,
           Risk, Position.Rank, Fantasy.Points, Ceiling.Fantasy.Points, Floor.Fantasy.Points),
  Fantasy_Projections <- Fantasy_Projections %>%
    mutate(Opportunities = (Pass.Attempts + Carries + Targets),
           Touches = Carries + Receptions,
           Value.Per.Opportunity = (VoR/Opportunities), 
           Fantasy.Points = Average.Fantasy.Points) %>%
    select(id, Player, Team, Position, Bye, Average.Auction.Value, Cost, Average.Draft.Position, Games.Played, Opportunities, Touches, Tier, Value.Rank, VoR, Ceiling.VoR, Floor.VoR, Dropoff,
           Risk, Position.Rank, Fantasy.Points, Ceiling.Fantasy.Points, Floor.Fantasy.Points))

### Reorder the file
if(week >= 1){Fantasy_Projections <- Fantasy_Projections %>%
                          arrange(desc(Fantasy.Points))}
if(week == 0){Fantasy_Projections <- Fantasy_Projections %>%
         arrange(desc(VoR))}
       

### Change 0 ADP
Fantasy_Projections <- as.data.table(Fantasy_Projections)
Fantasy_Projections[which(Average.Draft.Position == 0), Average.Draft.Position := 170]

### Round Everything
Average_Fantasy_Projections[,5:56] <- round(Average_Fantasy_Projections[,5:56], 2)
Fantasy_Projections[,5:21] <- round(Fantasy_Projections[,5:21], 2)
