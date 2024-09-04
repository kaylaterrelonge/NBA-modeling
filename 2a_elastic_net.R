# Elastic Net Model ----

library(tidyverse)
library(tidymodels)

set.seed(1110)



# loading in model components
load("model_info/nba_elastic_1.rda")
load("model_info/nba_elastic_2.rda")
load("model_info/nba_elastic_3.rda")

# running recipe 1 mod
tuned_elastic_1 <- tune_grid(
  elastic_workflow_1, 
  nba_folds,
  elastic_grid,
  parallel_over = "everything")

write_rds(tuned_elastic_1, file = "results/tuned_elastic_1.rds")


# recipe 2
tuned_elastic_2 <- tune_grid(
  elastic_workflow_2, 
  nba_folds,
  elastic_grid,
  parallel_over = "everything")

write_rds(tuned_elastic_2, file = "results/tuned_elastic_2.rds")

# recipe 3
tuned_elastic_3 <- tune_grid(
  elastic_workflow_3, 
  nba_folds,
  elastic_grid,
  parallel_over = "everything")

write_rds(tuned_elastic_3, file = "results/tuned_elastic_3.rds")


