# Random Forest Model (Recipe 1) ----

library(tidyverse)
library(tidymodels)

set.seed(1110)




# load in model info
load("model_info/nba_rf_1.rda")

# running models
tuned_rf_1 <- tune_grid(
  rf_workflow_1, 
  nba_folds,
  rf_grid,
  parallel_over = "everything")

write_rds(tuned_rf_1, file = "results/tuned_rf_1.rds")