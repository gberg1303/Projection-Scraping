### Add Cost Multiplier
#Apply 10% price premium to 33 players with highest projected points, apply 10% price deflation for players lower than rank 66
Average_Fantasy_Projections$Cost <- 0
Average_Fantasy_Projections <- as.data.table(Average_Fantasy_Projections)
Average_Fantasy_Projections[which(Value.Rank <= 45), Cost := Average.Auction.Value * 1.1]
Average_Fantasy_Projections[which(Value.Rank >= 46 & Average_Fantasy_Projections$Value.Rank <= 90), Cost := Average.Auction.Value]
Average_Fantasy_Projections[which(Value.Rank >= 91), Cost := Average.Auction.Value * 1]
Average_Fantasy_Projections <- as.data.table(Average_Fantasy_Projections)
Average_Fantasy_Projections[which(Average_Fantasy_Projections$Cost == 0), Cost := 1]
Average_Fantasy_Projections$Cost <- ceiling(Average_Fantasy_Projections$Cost)
Average_Fantasy_Projections <- Average_Fantasy_Projections %>%
  mutate(Cost = ifelse(Cost >=8 | Cost <= 21, Cost + 2, Cost))