# Model Results & Comparisons ----

# load pkgs ----
library(tidymodels)
library(tidyverse)
 
set.seed(1110)

#####################################################################
# collecting elastic net results
elast_net_1 <- read_rds("results/tuned_elastic_1.rds")
elast_net_2 <- read_rds("results/tuned_elastic_2.rds")
elast_net_3 <- read_rds("results/tuned_elastic_3.rds")

en_rec_1 <- show_best(elast_net_1, metric = "rmse")[1,]
en_rec_2 <- show_best(elast_net_2, metric = "rmse")[1,]
en_rec_3 <- show_best(elast_net_3, metric = "rmse")[1,]
#####################################################################
# collecting knn results

knn_1 <- read_rds("results/tuned_knn_1.rds")
knn_2 <- read_rds("results/tuned_knn_2.rds")
knn_3 <- read_rds("results/tuned_knn_3.rds")

knn_rec_1 <- show_best(knn_1, metric = "rmse")[1,]
knn_rec_2 <- show_best(knn_2, metric = "rmse")[1,]
knn_rec_3 <- show_best(knn_3, metric = "rmse")[1,]
#####################################################################
# collecting rf results

rf_1 <- read_rds("results/tuned_rf_1.rds")
rf_2 <- read_rds("results/tuned_rf_2.rds")
rf_3 <- read_rds("results/tuned_rf_3.rds")

rf_rec_1 <- show_best(rf_1, metric = "rmse")[1,]
rf_rec_2 <- show_best(rf_2, metric = "rmse")[1,]
rf_rec_3 <- show_best(rf_3, metric = "rmse")[1,]
#####################################################################
# collecting lm results

lm_1 <- read_rds("results/fit_lm_1.rds")
lm_2 <- read_rds("results/fit_lm_2.rds")
lm_3 <- read_rds("results/fit_lm_3.rds")

lm_rec_1 <- show_best(lm_1, metric = "rmse")[1,]
lm_rec_2 <- show_best(lm_2, metric = "rmse")[1,]
lm_rec_3 <- show_best(lm_3, metric = "rmse")[1,]
#####################################################################
# collecting bt result

bt_1 <- read_rds("results/tuned_bt_1.rds")
bt_2 <- read_rds("results/tuned_bt_2.rds")
bt_3 <- read_rds("results/tuned_bt_3.rds")

bt_rec_1 <- show_best(bt_1, metric = "rmse")[1,]
bt_rec_2 <- show_best(bt_2, metric = "rmse")[1,]
bt_rec_3 <- show_best(bt_3, metric = "rmse")[1,]
#####################################################################
# collecting null result

null_fit <- read_rds("results/fit_null.rds")

null <- null_fit %>% 
  collect_metrics() %>% 
  filter(.metric == "rmse") 

#####################################################################

## comparing results

rec_1_best <- tibble(model = c("NULL", "LM", "EN", "KNN", "RF", "BT"),
                     recipe = c("1", "1", "1", "1", "1", "1"),
                     rmse = c(null$mean, lm_rec_1$mean, en_rec_1$mean,
                              knn_rec_1$mean,
                              rf_rec_1$mean, bt_rec_1$mean),
                     se = c(null$std_err,  lm_rec_1$std_err, en_rec_1$std_err,
                            knn_rec_1$std_err,
                            rf_rec_1$std_err, bt_rec_1$std_err)) %>% 
  arrange(rmse)
# boosted tree model performed the best

rec_2_best <- tibble(model = c("NULL", "LM", "EN", "KNN", "RF", "BT"),
                     recipe = c("2", "2", "2", "2", "2", "2"),
                     rmse = c(null$mean, lm_rec_2$mean, en_rec_2$mean,
                              knn_rec_2$mean,
                              rf_rec_2$mean, bt_rec_2$mean),
                     se = c(null$std_err,  lm_rec_2$std_err, en_rec_2$std_err,
                            knn_rec_2$std_err,
                            rf_rec_2$std_err, bt_rec_2$std_err)) %>% 
  arrange(rmse)

# boosted tree model performed the best

rec_3_best <- tibble(model = c("NULL", "LM", "EN", "KNN", "RF", "BT"),
                     recipe = c("3", "3", "3", "3", "3", "3"),
                     rmse = c(null$mean, lm_rec_3$mean, en_rec_3$mean,
                              knn_rec_3$mean,
                              rf_rec_3$mean, bt_rec_3$mean),
                     se = c(null$std_err,  lm_rec_3$std_err, en_rec_3$std_err,
                            knn_rec_3$std_err,
                            rf_rec_3$std_err, bt_rec_3$std_err)) %>% 
  arrange(rmse)

write_rds(rec_1_best, file = "results/rec_1_comparison.rds")
write_rds(rec_2_best, file = "results/rec_2_comparison.rds")
write_rds(rec_3_best, file = "results/rec_3_comparison.rds")
# boosted tree model performed the best


# boosted tree model performed the best

# comparing the best tuning metrics for each model type

knn_best <- tibble(model = c("KNN", "KNN", "KNN"),
                   recipe = c("1", "2", "3"),
                   neighbors = c(knn_rec_1$neighbors, knn_rec_2$neighbors,
                                 knn_rec_3$neighbors),
                   rmse = c(knn_rec_1$mean, knn_rec_2$mean,
                            knn_rec_3$mean),
                   se = c(knn_rec_1$std_err, knn_rec_2$std_err,
                          knn_rec_3$std_err)) %>% 
  arrange(rmse)

en_best <- tibble(model = c("en", "en", "en"),
                  recipe = c("1", "2", "3"),
                  mixture = c(en_rec_1$mixture, en_rec_2$mixture,
                              en_rec_3$mixture),
                  penalty = c(en_rec_1$penalty, en_rec_2$penalty,
                              en_rec_3$penalty),
                  rmse = c(en_rec_1$mean, en_rec_2$mean,
                           en_rec_3$mean),
                  se = c(en_rec_1$std_err, en_rec_2$std_err,
                         en_rec_3$std_err)) %>% 
  arrange(rmse)

rf_best <- tibble(model = c("rf", "rf", "rf"),
                  recipe = c("1", "2", "3"),
                 mtry = c(rf_rec_1$mtry, rf_rec_2$mtry,
                          rf_rec_3$mtry),
                  rmse = c(rf_rec_1$mean, rf_rec_2$mean,
                           rf_rec_3$mean),
                  se = c(rf_rec_1$std_err, rf_rec_2$std_err,
                         rf_rec_3$std_err)) %>% 
  arrange(rmse)

# saving results
save(rf_best, knn_best, en_best, file = "results/best_mods_tuning.rda")

# comparing best performers across recipes
top_mod_1 <- rec_1_best[1,]
top_mod_2 <- rec_2_best[1,]
top_mod_3 <- rec_3_best[1,]


best_mod <- tibble(model = c(top_mod_1$model, top_mod_2$model, 
                             top_mod_3$model),
                   trees = c(bt_rec_1$trees, bt_rec_2$trees, bt_rec_3$trees),
                   mtry = c(bt_rec_1$mtry, bt_rec_2$mtry, bt_rec_3$mtry),
                   learn_rate = c(bt_rec_1$learn_rate, 
                                  bt_rec_2$learn_rate, bt_rec_3$learn_rate),
                   log_rmse = c(top_mod_1$rmse, top_mod_2$rmse, 
                                      top_mod_3$rmse),
                   recipe = c("1", "2","3"),
                   se = c(top_mod_1$se, top_mod_2$se,
                          top_mod_3$se)) %>% 
  # looking at the rmse on the original scale
  mutate(rmse = 10^log_rmse) %>% 
  arrange(rmse)

# the best model is with the boosted tree with recipe 3
# mtry = 17, trees = 1720, learn_rate = 0.0956

write_rds(best_mod, file = "results/best_mod.rds")

# visualizing the results
ggplot(best_mod, aes(x = recipe, y = log_rmse)) +
  geom_point() +
  geom_errorbar(aes(ymin = log_rmse - 1.96*se,
                    ymax = log_rmse + 1.96*se), width = 0.2) +
  theme_minimal()

##############################################################################

## finalizing the workflow

# saving out information to finalize workflow
save(bt_rec_3, bt_3, file = "final_model/final_bt_metrics.rda")