# KNN Model ----

# load pkgs & set seed
library(tidyverse)
library(tidymodels)
set.seed(1110)



# load in model info
load("model_info/nba_knn_1.rda")
load("model_info/nba_knn_2.rda")
load("model_info/nba_knn_3.rda")

# running models
tuned_knn_1 <- tune_grid(
  knn_workflow_1, 
  nba_folds,
  knn_grid,
  parallel_over = "everything")

write_rds(tuned_knn_1, file = "results/tuned_knn_1.rds")

tuned_knn_2 <- tune_grid(
  knn_workflow_2, 
  nba_folds,
  knn_grid,
  parallel_over = "everything")

write_rds(tuned_knn_2, file = "results/tuned_knn_2.rds")

tuned_knn_3 <- tune_grid(
  knn_workflow_3, 
  nba_folds,
  knn_grid,
  parallel_over = "everything")

write_rds(tuned_knn_3, file = "results/tuned_knn_3.rds")
