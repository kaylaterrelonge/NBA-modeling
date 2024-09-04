# Null Model ----

library(tidymodels)
library(tidyverse)

# load in model info
load("model_info/nba_null.rda")

# running null model
fit_null <- fit_resamples(null_workflow, resamples = nba_folds, 
                          control = control_resamples(save_pred = TRUE))

# writing out results
write_rds(fit_null, file = "results/fit_null.rds")
