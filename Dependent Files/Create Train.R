### Create Train dataset for Optimizer
Average_Fantasy_Projections <- data.frame(Average_Fantasy_Projections)
train <- Average_Fantasy_Projections[c("id", "Player", "Position", "Bye", "Average.Fantasy.Points", "Risk", "VoR", "Average.Auction.Value", "Cost", "Floor.Fantasy.Points", "Dropoff")]
train <- data.table(train)
train[which(train$Cost == 0), Cost := 1]
train$dk_total <- 1
placeholder <- data.frame(1234567, "placeholder", "PLC", 0, 0,0,0,0,0,0,0,1)
colnames(placeholder) <- colnames(train)
train <- rbind(train, placeholder)
train <- train %>% arrange(desc(Average.Fantasy.Points))