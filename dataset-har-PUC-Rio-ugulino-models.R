library(data.table)
library(h2o)

#### Setup ####
h2o.init(max_mem_size = "4g", nthreads = -1)   ## starts Java server (R connects via REST)

dx_train <- as.h2o(d_train, "train")
dx_valid <- as.h2o(d_valid, "valid")
dx_test <- as.h2o(d_test, "test")

dm_train <- as.h2o(mini_train, "mini_train")
dm_valid <- as.h2o(mini_valid, "mini_valid")
dm_test <- as.h2o(mini_test, "mini_test")

d_x_idxs = 8:ncol(dx_train) - 1 # Starting from 8 due to H2O
d_y_idxs = ncol(dx_train)

#### Grid Search with Distributed Random Forest ####
system.time({
  drf <- h2o.grid("drf", x = d_x_idxs, y = d_y_idxs, 
                  training_frame = dm_train, validation_frame = dm_valid,
                  hyper_params = list(ntrees = c(100, 250, 500),
                                      max_depth = c(10, 15, 20, 25),
                                      nbins = c(50, 100, 150)),
                  stopping_rounds = 5, stopping_tolerance = 1e-3)
})
drf

#### Grid Search with Gradient Boosting Method ####

system.time({
  gbm <- h2o.grid("gbm", x = d_x_idxs, y = d_y_idxs, 
                  training_frame = dx_train, validation_frame = dx_valid,
                  hyper_params = list(ntrees = c(100, 250, 500),
                                      max_depth = c(10, 15, 20, 25),
                                      learn_rate = c(0.05, 0.1, 0.2),
                                      nbins = c(50, 100, 150)),
                  stopping_rounds = 5, stopping_tolerance = 1e-3)
})

gbm



do.call(rbind, lapply(gbm@model_ids, function(m_id) {
  mm <- h2o.getModel(m_id)
  hyper_params <- mm@allparameters
  data.table(m_id = m_id, 
             auc = h2o.performance(mm, dx_test)@metrics$AUC,
             max_depth = hyper_params$max_depth,
             learn_rate = hyper_params$learn_rate )
}))[order(-auc)]


#### Neural network ####
system.time({
  nn <- h2o.deeplearning(x = d_x_idxs, y = d_y_idxs, 
                         training_frame = dx_train, validation_frame = dx_valid,
                         activation = "Rectifier", hidden = c(200,200), epochs = 100,
                         stopping_rounds = 3, stopping_tolerance = 0)
})

nn
h2o.auc(nn)
h2o.auc(h2o.performance(nn, dx_test))

#### Neural network with regularization (L1, L2, dropout) ####

system.time({
  md <- h2o.deeplearning(x = d_x_idxs, y = d_y_idxs, 
                         training_frame = dx_train, validation_frame = dx_valid,
                         activation = "RectifierWithDropout", hidden = c(200,200), epochs = 100,
                         input_dropout_ratio = 0.2, hidden_dropout_ratios = c(0.2,0.2),
                         l1 = 1e-4, l2 = 1e-4,
                         stopping_rounds = 3, stopping_tolerance = 0)
})
md
h2o.auc(md)
h2o.auc(h2o.performance(md, dx_test))