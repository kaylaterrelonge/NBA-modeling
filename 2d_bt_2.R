# Boosted Tree Model (Recipe 2) ----

# load pkgs & set seed
library(tidyverse)
library(tidymodels)

set.seed(1110)


# load in model info
load("model_info/nba_bt_2.rda")

# running models
tuned_bt_2 <- tune_grid(
  bt_workflow_2, 
  nba_folds,
  bt_grid,
  parallel_over = "everything")

write_rds(tuned_bt_2, file = "results/tuned_bt_2.rds")
