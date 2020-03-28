### Calculate Dropoff
Average_Fantasy_Projections <- Average_Fantasy_Projections %>%
  group_by(Position) %>%
  arrange(Average.Fantasy.Points) %>%
  mutate(Dropoff = abs(Average.Fantasy.Points - lag(Average.Fantasy.Points, default = 0)))

### Repeat to make it work?
Average_Fantasy_Projections <- Average_Fantasy_Projections %>%
  group_by(Position) %>%
  arrange(Average.Fantasy.Points) %>%
  mutate(Dropoff = abs(Average.Fantasy.Points - lag(Average.Fantasy.Points, default = 0)))
