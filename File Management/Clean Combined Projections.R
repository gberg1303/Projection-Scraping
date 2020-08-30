### Bind all the projections together
Combined_Projections <- matrix(nrow = 1, ncol = 1)
ifelse(sources == "CBS",Combined_Projections <- smartbind(Combined_Projections, CBS_Projections), print(0))
ifelse(sources == "ESPN", Combined_Projections <- smartbind(Combined_Projections, ESPN_Projections), print(0))
ifelse(sources == "Sleeper", Combined_Projections <- smartbind(Combined_Projections, Sleeper_Projections), print(0))
ifelse(sources == "FantasySharks", Combined_Projections <- smartbind(Combined_Projections, FantasySharks_Projections), print(0))
ifelse(sources == "Yahoo", Combined_Projections <- smartbind(Combined_Projections, Yahoo_Projections), print(0))
ifelse(sources == "FantasyPros", Combined_Projections <- smartbind(Combined_Projections, FantasyPros_Projections), print(0))
ifelse(sources == "NFL", Combined_Projections <- smartbind(Combined_Projections, NFL_Projections), print(0))

### Remove Player NA
Combined_Projections <- Combined_Projections %>%
  filter(!is.na(Player))
  
### Remove Funky Characters
Combined_Projections$Player <- str_replace_all(Combined_Projections$Player, "III ", "")
Combined_Projections$Player <- str_replace_all(Combined_Projections$Player, "II ", "")
Combined_Projections$Player <- str_replace_all(Combined_Projections$Player, "Jr.", "")
Combined_Projections$Player <- str_replace_all(Combined_Projections$Player, "Sr.", "")
Combined_Projections$Player <- str_replace_all(Combined_Projections$Player, "IV ", " ")
Combined_Projections$Player <- str_replace_all(Combined_Projections$Player, "V ", " ")
Combined_Projections$Player <- str_replace_all(Combined_Projections$Player, "É", "E")

### Trim White Space One Last Time
Combined_Projections$Player <- sub("^\\s*(\\S+\\s+\\S+).*", "\\1", Combined_Projections$Player) ## Clear everything after the second space 
Combined_Projections$Team <- sub("^\\s*(\\S+\\s+\\S+).*", "\\1", Combined_Projections$Team) ## Clear everything after the second space 
Combined_Projections$Position <- sub("^\\s*(\\S+\\s+\\S+).*", "\\1", Combined_Projections$Position) ## Clear everything after the second space 
Combined_Projections$Player <- gsub("[.]","",Combined_Projections$Player) 
Combined_Projections$Team <- gsub(" ","",Combined_Projections$Team) 
Combined_Projections$Team <- toupper(Combined_Projections$Team)
Combined_Projections$Position <- gsub(" ","",Combined_Projections$Position) 
Combined_Projections$Position <- trimws(Combined_Projections$Position)

### Fix Capitalization in Names
Combined_Projections$Player <- sapply(Combined_Projections$Player, toupper)

### Change Some Positions
Combined_Projections$Position <- gsub("FB","RB",Combined_Projections$Position) 
Combined_Projections$Position <- gsub("OT","TE",Combined_Projections$Position) 

### Change to Numeric
Combined_Projections$FGM.XP <- as.numeric(Combined_Projections$FGM.XP)
Combined_Projections$FGM.1_39 <- as.numeric(Combined_Projections$FGM.1_39)
Combined_Projections$FGM.40_49 <- as.numeric(Combined_Projections$FGM.40_49)
Combined_Projections$FGM.50. <- as.numeric(Combined_Projections$FGM.50.)

### Change Mitchell Trubisky
Combined_Projections <- as.data.table(Combined_Projections)
Combined_Projections[which(Combined_Projections$Player == "MITCH TRUBISKY"), Player := "MITCHELL TRUBISKY"]

### Clean Team Names
Combined_Projections <- Combined_Projections %>%
  mutate(Team = gsub("OAK", "LV", Team),
         Team = gsub("LVR", "LV", Team),
         Team = gsub("ARZ", "ARI", Team),
         Team = gsub("JAC", "JAX", Team))


