library(jsonlite)
library(data.table)
library(tidyverse)
library(gtools)
library(stringr)

### Set Week
if(week == 0){week_no <- paste0(10, season)}
if(week > 0){week_no <- paste0(11, season, week)}
#if(week == 000){week_no <- paste0(00, season)}

### Get Player
ESPN_JSON <- fromJSON(paste0("https://fantasy.espn.com/apis/v3/games/ffl/seasons/", season, "/segments/0/leaguedefaults/1?view=kona_player_info"))


### Put Important Information Together
ESPN_Projections <- data.frame(
  "Platform" = c("ESPN"),
  "id" = ESPN_JSON[["players"]][["id"]],
  "Player" = ESPN_JSON[["players"]][["player"]][["fullName"]],
  "Team ID" = ESPN_JSON[["players"]][["player"]][["proTeamId"]],
  "Position ID" = ESPN_JSON[["players"]][["player"]][["defaultPositionId"]],
  "Auction Value" = ESPN_JSON[["players"]][["player"]][["draftRanksByRankType"]][["PPR"]][["auctionValue"]],
  "Average Auction Value" = round(ESPN_JSON[["players"]][["player"]][["ownership"]][["auctionValueAverage"]], 2),
  "Average Draft Position" = ESPN_JSON[["players"]][["player"]][["ownership"]][["averageDraftPosition"]]
)


### Change Team ID to Team
espn_teamid_key <- data.frame(
  "Team ID" = 0:34,
  "Team" = c("FA", "ATL", "BUF", "CHI", "CIN", "CLE",
             "DAL", "DEN", "DET", "GB", "TEN",
             "IND", "KC", "OAK", "LAR", "MIA",
             "MIN", "NE", "NO", "NYG", "NYJ",
             "PHI", "ARI", "PIT", "LAC", "SF",
             "SEA", "TB", "WAS", "CAR", "JAC",
             NA, NA, "BAL", "HOU"))
espn_positionid_key <- data.frame(
  "Position ID" = c(1:5, 16),
  "Position" = c("QB", "RB", "WR", "TE", "K", "DST")
)
ESPN_Projections <- merge(espn_teamid_key, ESPN_Projections,  by = c("Team.ID"))
ESPN_Projections <- merge(espn_positionid_key, ESPN_Projections, by = c("Position.ID"), all = TRUE)
ESPN_Projections <- ESPN_Projections %>%
  select(-c("Position.ID", "Team.ID")) %>%
  select(id, Player, Team, Position, everything())

### Clean and Save
if(week == 0){week_no <- paste0("Draft")}
if(week > 0){week_no <- paste0(week)}
assign(paste0("ESPN_Projections"), ESPN_Projections)
rm(espn_stat_projections, espn_stat_projections_placeholder, espn_stat_projections_player, ESPN_JSON, espn_teamid_key, espn_positionid_key, espn_stat_projections_placeholder_placeholder, week_no)
