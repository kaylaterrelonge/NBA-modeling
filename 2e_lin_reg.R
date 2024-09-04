# Linear Regression Model ----

# load pkgs & set seed
library(tidyverse)
library(tidymodels)
set.seed(1110)


# load in model info
load("model_info/nba_lm_1.rda")
load("model_info/nba_lm_2.rda")
load("model_info/nba_lm_3.rda")

# saving predictions
keep_pred <- control_resamples(save_pred = TRUE)

# fitting model

fit_lm_1 <- fit_resamples(lm_workflow_1, resamples = nba_folds, 
              control = keep_pred)

fit_lm_2 <- fit_resamples(lm_workflow_2, resamples = nba_folds, 
                      control = keep_pred)

fit_lm_3 <- fit_resamples(lm_workflow_3, resamples = nba_folds, 
                          control = keep_pred)
# writing out results
write_rds(fit_lm_1, file = "results/fit_lm_1.rds")
write_rds(fit_lm_2, file = "results/fit_lm_2.rds")
write_rds(fit_lm_3, file = "results/fit_lm_3.rds")