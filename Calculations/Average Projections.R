library(tidyverse)
### Filter Out 0 Projections
Combined_Projections <- Combined_Projections %>%
  filter(Individual.Fantasy.Points > 0)

### Remove CBS if week changes
if(sources == "CBS"){
if(week == 0){if(max(Combined_Projections %>% filter(Platform == "CBS") %>% select(Individual.Fantasy.Points)) < 100){Combined_Projections <- Combined_Projections %>% filter(Platform != "CBS")}}
}
### Get Average Projections
Average_Fantasy_Projections <- Combined_Projections %>%
  group_by(Player) %>%
  group_by(Team, add = TRUE) %>%
  group_by(Position, add = TRUE) %>%
  select(-Individual.Fantasy.Points) %>%
  summarise_all(mean, na.rm = TRUE)