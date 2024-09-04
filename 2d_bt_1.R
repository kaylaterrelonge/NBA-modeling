# Boosted Tree Model (Recipe 1) ----

# load pkgs & set seed
library(tidyverse)
library(tidymodels)
set.seed(1110)

# load in model info
load("model_info/nba_bt_1.rda")


# running models
tuned_bt_1 <- tune_grid(
  bt_workflow_1, 
  nba_folds,
  bt_grid,
  parallel_over = "everything")

write_rds(tuned_bt_1, file = "results/tuned_bt_1.rds")