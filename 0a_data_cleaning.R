# Data Import & Cleaning ----

## load-pkgs ----
library(tidymodels)
library(tidyverse)
library(janitor)
library(forcats)

## data-import ----
nba <- read_csv("data/processed_data/nba_players.csv")

## data-cleaning ----
nba <- nba %>% 
  # fixing any inconsistency in naming
  janitor::clean_names() %>% 
  # changing variables as factor
  mutate(conference = as.factor(conference),
         team = as.factor(team),
         team_class = as.factor(team_class),
         pos = as.factor(pos),
         three_point_perc = x3p_percent,
         three_point_attempt = x3pa,
         three_point_made = x3_pm) %>% 
  select(-c(x3_pm, x3pa, x3p_percent)) %>% 
# writing out to data folder
write_rds("data/processed_data/nba_players.rds")
