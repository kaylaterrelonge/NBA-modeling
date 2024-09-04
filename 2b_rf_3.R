# Random Forest Model (Recipe 3) ----

library(tidyverse)
library(tidymodels)

set.seed(1110)



# load in model info
load("model_info/nba_rf_3.rda")


# running models
tuned_rf_3 <- tune_grid(
  rf_workflow_3, 
  nba_folds,
  rf_grid,
  parallel_over = "everything")

write_rds(tuned_rf_3, file = "results/tuned_rf_3.rds")



