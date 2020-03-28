#install.packages(readxl)
#install.packages("lpSolveAPI")
library(lpSolveAPI)
library(dplyr)

##
## FUNCTION ARGUMENTS:
##
##
## constraint: 'none' for no constraints on lineup configuration
##
## Function returns the top lineup under your constraints, with each team's
## expected total points and the total salary used (will be under the cap)

### For the file you import, make sure that there is a placeholder at the bottom with ID of 1234567 , position is "plc"
### and zero in every category,
### ALSO  there needs to be a column dk_total where every Player has 1

find_teams <- function(train, cap, constraint = c("none", "all_diff", "no_opp"), 
                       league = c("Jonathan"), setPlayers = NULL, removeteams = NULL) {
  
  ##the file that you input should be renamed to train and train sould have these columns in this exact order
  colnames(train) <- c("id",	"Player",	"position",	"bye",	"points", "risk","vor","auctionValue", "cost", "Points.Floor", "dropoff", "dk_total")
  
  ## set constraints to use
  defense <- ifelse(train$position == "DST", 1, 0)
  qb <- ifelse(train$position == "QB", 1, 0)
  wr <- ifelse(train$position == "WR", 1, 0)
  te <- ifelse(train$position == "TE", 1, 0)
  rb <- ifelse(train$position == "RB", 1, 0)
  k <- ifelse(train$position == "K", 1, 0)
  dl <- ifelse(train$position == "DL", 1, 0)
  db <- ifelse(train$position == "DB", 1, 0)
  lb <- ifelse(train$position == "LB", 1, 0)
  plc <-ifelse(train$position == "PLC", 1, 0)
  ## number of decision variables is equal to the number of fantasy Players/teams
  lpfantasy <- make.lp(0, nrow(train))
  
  ## Set objective function with the expected number of points
  set.objfn(lpfantasy, train$vor)
  lp.control(lpfantasy, sense='max')
  
  
  ##Minimize Risk
  #set.objfn(lpfantasy, train$vor)
  #lp.control(lpfantasy, sense='min')
  add.constraint(lpfantasy, train$vor, ">", 0)

  ## Make sure the decision variables are binary
  set.type(lpfantasy, seq(1, nrow(train), by=1), type = c("binary"))
  
  #Set a limit on the amount of risk you want
  add.constraint(lpfantasy, train$risk, "<", 55)

  ## Add some contraints
  ## DO NOT CHANGE THESE
  add.constraint(lpfantasy, wr, ">", 2)
  add.constraint(lpfantasy, rb, ">", 2)
  add.constraint(lpfantasy, te, ">", 1)
  ## position Selection (THIS TELLS IT HOW MANY OF EACH position TO TAKE. YOU CAN CHANGE THE NUMBER AND SYNTAX TO
  ## AS THE DRAFT GOES ON TO CUSTOMIZE WHAT positionS YOU HAVE LEFT).
  { add.constraint(lpfantasy, defense, "=", 1)
    add.constraint(lpfantasy, qb, "=", 1)
    add.constraint(lpfantasy, wr, "<=", 4)
    add.constraint(lpfantasy, rb, "<=", 4)
    add.constraint(lpfantasy, te, "<=", 2)
    add.constraint(lpfantasy, k, "=", 1)
    add.constraint(lpfantasy, dl, "=", 0)
    add.constraint(lpfantasy, db, "=", 0)
    add.constraint(lpfantasy, lb, "=", 0)
    add.constraint(lpfantasy, plc, "=", 1)
  }
  ## IMPORTANT - This is how many Players the algorithhm will spit out: #ofPlayersinyourleague+1
  ## THe plus one is for the placeholder
  add.constraint(lpfantasy, train$dk_total, "=", 10+1)
  
  ## DEPRECATED, but can uncomment if you want to impose the restrictions described on the next two lines
  ## Make sure not to select more than one WR, or more than one RB from a single team
  ## Constraint: make sure not to select a WR/TE, WR/RB, RB/TE combo from same team
  #for(i in 1:length(team_names)){
  #  position_check <- ifelse((train$Team == team_names[i] & 
  #                             (train$position == "WR" | train$position == "RB" | train$position == "TE")), 1, 0)
  #  add.constraint(lpfantasy, position_check, "<=", 1)
  #}
  
  ## Add monetary constraint, max salary for the team
  add.constraint(lpfantasy, train$cost, "<=", cap)
  
  team <- data.frame(matrix(0, 1, ncol(train) + 4))
  colnames(team) <- c(colnames(train), "TeamSalary", "TotalVOR", "TotalRisk", "TotalPoints")
  
  ## Set constraints that each Player here must be in lineup
  if(!is.null(setPlayers)){
    for(k in 1:nrow(setPlayers)) {
      add.constraint(lpfantasy, ifelse(setPlayers$id[k] == train$id, 1, 0), "=", 1)
    }
  }
  
 
  
  ## Solve the model, if this returns 0 an optimal solution is found
  solve(lpfantasy)
  if(solve(lpfantasy) != 0)
  stop("Optimization failed at some step")
  
  ## Get the Players on the team
  team_select <- subset(data.frame(train, get.variables(lpfantasy)), get.variables.lpfantasy. == 1)
  team_select$get.variables.lpfantasy. <- NULL
  team_select$TeamSalary <- sum(team_select$cost)
  team_select$TotalVOR <- sum(team_select$vor)
  team_select$TotalPoints <- sum(team_select$points)
  team_select$TotalRisk <- sum(team_select$risk)
  team <- rbind(team, team_select)
  team <- team[-1,]
  rownames(team) <- NULL
  team
  
}