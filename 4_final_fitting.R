# Final Fitting ----

## load pkgs ----
library(tidyverse)
library(tidymodels)
set.seed(1110)

## reading in info ----
# reading in final workflow and recipe
load("model_info/nba_bt_3.rda")

# reading in the tuned parameters
load("final_model/final_bt_metrics.rda")

# reading in training and testing data
load("results/nba_split.rda")

## finalizing workflow ----
final_workflow <- bt_workflow_3 %>% 
  finalize_workflow(select_best(bt_3, metric = "rmse"))

## fitting model ----

# creating a metric set
nba_metrics <- metric_set(rmse, rsq)

# fitting to entire training set
nba_final_fit <- fit(final_workflow, nba_train)

# predicting on testing data
nba_predicted <- predict(nba_final_fit, nba_test) %>% 
  bind_cols(nba_test %>% 
              select(log_pts, pts)) %>% 
# adding the predicted values on the original scale
mutate(log_pred = .pred,
       pred_og = 10^.pred) %>% 
  select(-.pred)

# metrics
nba_performance_log <- nba_predicted %>% 
  nba_metrics(truth = log_pts, estimate = log_pred)  %>% 
  mutate(scale = c("log", "log"))


nba_performance <- nba_predicted %>% 
  nba_metrics(truth = pts, estimate = pred_og) %>% 
  mutate(scale = c("original", "original"))

performance_metrics <- full_join(nba_performance_log, nba_performance)

# plotting results
ggplot(nba_predicted, mapping = aes(x = pred_og, y = pts)) +
  geom_point() + 
  geom_smooth(method = "lm") +
  labs(title = "The Predicted Values v. The Actual Values on the Original Scale")

ggplot(nba_predicted, mapping = aes(x = log_pts, y = log_pred)) +
  geom_point() +
  geom_smooth(method = "lm") +
  labs(title = "The Predicted Values v. The Actual Values on the Log Scale")


# writing out results
save(performance_metrics, nba_predicted_plot, 
     log_predicted_plot, nba_predicted, 
     file = "final_model/final_bt_metrics.rda")
