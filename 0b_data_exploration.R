# Data Exploration ----

## load-pkgs ----
library(tidymodels)
library(tidyverse)

set.seed(1110)

## data import ----

nba <- read_rds("data/processed_data/nba_players.rds")

# skimming data for missingness and class imbalance
skimr::skim_without_charts(nba)

# looking at factors for class imbalances
nba %>% 
  group_by(team) %>% 
  count() %>% 
  print(n = 32)

nba %>% 
  group_by(pos) %>% 
  count() %>% 
  print()
# guard forward is lower than others 

## data exploration ----

# loading in sample of data from the training set
load("results/nba_split.rda")

# random sample for eda
eda_train <- nba_train %>% 
  slice_sample(n = 200)

# looking at distribution of outcome var
eda_train %>% 
  ggplot(mapping = aes(x = pts)) +
  geom_boxplot()

eda_train %>% 
  ggplot(mapping = aes(pts)) +
  geom_histogram(color = "white", bins = 35)

# seems to be a left skew
# trying log transformations
eda_train %>% 
  ggplot(mapping = aes(log(pts))) +
  geom_histogram(color = "white", bins = 35)
# seems a little better 

eda_train %>% 
  ggplot(mapping = aes(log10(pts))) +
  geom_histogram(color = "white", bins = 35)

# sqrt transformation
eda_train %>% 
  ggplot(mapping = aes(sqrt(pts))) +
  geom_histogram(color = "white", bins = 35)
# still has a slight right skew, log transformation seems best
# no difference in log bases, use log base 10 transformation

## looking at relationship with numeric vars
corr_nba <- eda_train %>% 
  select(-c(pos, team, team_class, conference)) %>% 
  cor() 

corr_nba[4,]
# strong correlation with rank, fga, min, ftm, fta, and fgm
