# Random Forest Model (Recipe 2) ----

library(tidyverse)
library(tidymodels)

set.seed(1110)


# load in model info
load("model_info/nba_rf_2.rda")


# running models
tuned_rf_2 <- tune_grid(
  rf_workflow_2, 
  nba_folds,
  rf_grid)

write_rds(tuned_rf_2, file = "results/tuned_rf_2.rds")



