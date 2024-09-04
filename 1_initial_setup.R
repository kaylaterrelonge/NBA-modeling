# Initial Set-Up ----

## load-pkgs ----
library(tidymodels)
library(tidyverse)
library(kableExtra)
library(xgboost)

set.seed(1110)

## data import & split ----
nba <- read_rds("data/processed_data/nba_players.rds") %>% 
  mutate(log_pts = log10(pts)) %>% 
  select(-c(name, season))
  
# splitting data 
nba_split <- initial_split(nba, prop = 3/4, strata = pts)
nba_test <- testing(nba_split)
nba_train <- training(nba_split)

# setting aside portion for data exploration
  
# saving out set 
save(nba_split, nba_train, nba_test, file = "results/nba_split.rda")

## creating folds ----
nba_folds <- vfold_cv(nba_train, v = 5, 
                      repeats = 3, strata = log_pts)
## recipes ----

# kitchen sink recipe
nba_recipe_1 <- recipe(log_pts ~., data = nba_train) %>% 
  step_rm(pts,ftm, three_point_made, fgm) %>% 
  step_impute_mode(pos) %>% 
  step_impute_knn(per) %>% 
  step_dummy(all_nominal_predictors()) %>% 
  step_nzv(all_predictors()) 
  
prep(nba_recipe_1) %>% 
  bake(new_data = NULL)

# recipe with imputing
nba_recipe_2 <- recipe(log_pts ~., data = nba_train) %>% 
  step_rm(pts, ftm, three_point_made, fgm) %>% 
  step_impute_mode(pos) %>% 
  step_impute_knn(per) %>% 
  step_dummy(all_nominal_predictors()) %>% 
  step_interact(terms = ~ rank:gp) %>% 
  step_interact(terms = ~ fg_percent:min) %>% 
  step_interact(terms = ~ min:stl) %>% 
  step_nzv(all_predictors()) %>% 
  step_normalize(all_numeric_predictors()) 

rec_2 <- prep(nba_recipe_2) %>% 
  bake(new_data = NULL)

# removing missing values 
nba_recipe_3 <- recipe(log_pts ~., data = nba_train) %>% 
  step_rm(pts,ftm, three_point_made, fgm, per, pos) %>% 
  step_dummy(all_nominal_predictors()) %>% 
  step_nzv(all_predictors()) 

prep(nba_recipe_3) %>% 
  bake(new_data = NULL)
## setting engines and workflows ----

###############################################################################

### elastic net
elastic_model <- linear_reg(penalty = tune(), mixture = tune()) %>% 
  set_engine("glmnet") %>% 
  set_mode("regression")

elastic_params <- extract_parameter_set_dials(elastic_model)

elastic_grid <- grid_regular(elastic_params, levels = 5)

elastic_workflow_1  <- workflow() %>% 
  add_model(elastic_model) %>% 
  add_recipe(nba_recipe_1)

elastic_workflow_2 <- workflow() %>% 
  add_model(elastic_model) %>% 
  add_recipe(nba_recipe_2)

elastic_workflow_3 <- workflow() %>% 
  add_model(elastic_model) %>% 
  add_recipe(nba_recipe_3)

# writing out results
save(elastic_workflow_1, elastic_grid, nba_folds, nba_recipe_1, elastic_model,
     file = "model_info/nba_elastic_1.rda")
save(elastic_workflow_2, elastic_grid, nba_folds, nba_recipe_2, elastic_model,
     file = "model_info/nba_elastic_2.rda")
save(elastic_workflow_3, elastic_grid, nba_folds, nba_recipe_3, elastic_model,
     file = "model_info/nba_elastic_3.rda")
###############################################################################

### random forest

rf_model <- rand_forest(mtry = tune(),
                       trees = 500) %>% 
  set_engine("ranger") %>% 
  set_mode("regression")


rf_params <- extract_parameter_set_dials(rf_model) %>% 
  # range should be the sqrt of the number of predictors (26)
  update(mtry = mtry(range = c(1, 5)))

rf_grid <- grid_regular(rf_params, levels = 5)

rf_workflow_1 <- workflow() %>% 
  add_model(rf_model) %>% 
  add_recipe(nba_recipe_1)

rf_workflow_2 <- workflow() %>% 
  add_model(rf_model) %>% 
  add_recipe(nba_recipe_2)

rf_workflow_3 <- workflow() %>% 
  add_model(rf_model) %>% 
  add_recipe(nba_recipe_2)

# writing out results
save(rf_workflow_1, rf_grid, nba_folds, nba_recipe_1, rf_model,
     file = "model_info/nba_rf_1.rda")
save(rf_workflow_2, rf_grid, nba_folds, nba_recipe_2, rf_model,
     file = "model_info/nba_rf_2.rda")
save(rf_workflow_3, rf_grid, nba_folds, nba_recipe_3, rf_model,
     file = "model_info/nba_rf_3.rda")
###############################################################################

### knn
knn_model <- nearest_neighbor(neighbors = tune()) %>% 
  set_engine("kknn") %>% 
  set_mode("regression")

# setting parameters and creating grid
knn_params <- extract_parameter_set_dials(knn_model) %>% 
  update(neighbors = neighbors(range = c(1,25)))

knn_grid <- grid_regular(knn_params, levels = 5)

# making a workflow for each recipe 
knn_workflow_1 <- workflow() %>% 
  add_model(knn_model) %>% 
  add_recipe(nba_recipe_1)

knn_workflow_2 <- workflow() %>% 
  add_model(knn_model) %>% 
  add_recipe(nba_recipe_2)

knn_workflow_3 <- workflow() %>% 
  add_model(knn_model) %>% 
  add_recipe(nba_recipe_3)
# writing out results
save(knn_workflow_1, knn_grid, nba_folds, nba_recipe_1, knn_model,
     file = "model_info/nba_knn_1.rda")
save(knn_workflow_2, knn_grid, nba_folds, nba_recipe_2, knn_model,
     file = "model_info/nba_knn_2.rda")
save(knn_workflow_3, knn_grid, nba_folds, nba_recipe_3, knn_model,
     file = "model_info/nba_knn_3.rda")
###############################################################################

### boosted tree
bt_model <- boost_tree(mtry = tune(),
                      learn_rate = tune(),
                      trees = tune())%>% 
  set_engine("xgboost") %>% 
  set_mode("regression")

# setting params and grids
bt_params <- extract_parameter_set_dials(bt_model) %>% 
  update(mtry = mtry(range = c(1, 5)),
         learn_rate = learn_rate(range = c(0.3, 0.8),
                                 trans = scales:: identity_trans()))

bt_grid <- grid_regular(bt_params, levels = c(3, 3, 5))

# creating workflows
bt_workflow_1 <- workflow() %>% 
  add_model(bt_model) %>% 
  add_recipe(nba_recipe_1)

bt_workflow_2 <- workflow() %>% 
  add_model(bt_model) %>% 
  add_recipe(nba_recipe_2)

bt_workflow_3 <- workflow() %>% 
  add_model(bt_model) %>% 
  add_recipe(nba_recipe_3)

# saving results
save(bt_workflow_1, bt_grid, nba_folds, nba_recipe_1, bt_model,
     file = "model_info/nba_bt_1.rda")
save(bt_workflow_2, bt_grid, nba_folds, nba_recipe_2, bt_model,
     file = "model_info/nba_bt_2.rda")
save(bt_workflow_3, bt_grid, nba_folds, nba_recipe_3, bt_model,
     file = "model_info/nba_bt_3.rda")
################################################################################

## linear regression model

lm_model <- linear_reg(mode = "regression") %>% 
  set_engine("lm")

lm_workflow_1 <- workflow() %>% 
  add_model(lm_model) %>% 
  add_recipe(nba_recipe_1)

lm_workflow_2 <- workflow() %>% 
  add_model(lm_model) %>% 
  add_recipe(nba_recipe_2)

lm_workflow_3 <- workflow() %>% 
  add_model(lm_model) %>% 
  add_recipe(nba_recipe_3)

# writing out results
save(lm_workflow_1,nba_folds, nba_recipe_1, lm_model,
     file = "model_info/nba_lm_1.rda")
save(lm_workflow_2,nba_folds, nba_recipe_2, lm_model,
     file = "model_info/nba_lm_2.rda")
save(lm_workflow_3,nba_folds, nba_recipe_3, lm_model,
     file = "model_info/nba_lm_3.rda")
################################################################################

## null model

null_model <- null_model() %>% 
  set_engine("parsnip") %>% 
  set_mode("regression")

null_workflow <- workflow() %>% 
  add_model(null_model) %>% 
  add_recipe(nba_recipe_1)

# writing out results
save(null_workflow, nba_folds, null_model,
     file = "model_info/nba_null.rda")
