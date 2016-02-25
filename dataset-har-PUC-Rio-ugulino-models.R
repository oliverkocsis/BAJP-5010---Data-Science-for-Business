library(data.table)
library(h2o)

#### Setup ####
h2o.init(max_mem_size = "4g", nthreads = -1)   ## starts Java server (R connects via REST)

dx_train <- as.h2o(d_train, "train")
dx_valid <- as.h2o(d_valid, "valid")
dx_test <- as.h2o(d_test, "test")

#### Random Forest ####
system.time({
  md <- h2o.randomForest(x = 2:ncol(dx_train) - 1, y = 19, 
                         training_frame = dx_train, 
                         mtries = -1, ntrees = 500, max_depth = 20, nbins = 200)
})
md
h2o.auc(md) 
h2o.auc(h2o.performance(md, dx_test))

#### GBM ####
system.time({
  md <- h2o.gbm(x = 2:ncol(dx_train) - 1, y = ncol(dx_train), 
                training_frame = dx_train, validation_frame = dx_valid,
                max_depth = 15, ntrees = 500, learn_rate = 0.01, nbins = 200,
                stopping_rounds = 3, stopping_tolerance = 1e-3)
})
md
h2o.performance(md, dx_test)

#### GBM with cross validation ####
system.time({
  md <- h2o.gbm(x = 2:ncol(dx_train) - 1, y = ncol(dx_train), 
                training_frame = dx_train, 
                max_depth = 15, ntrees = 500, learn_rate = 0.01, nbins = 200,
                nfolds = 5,
                stopping_rounds = 3, stopping_tolerance = 1e-3)
})
md
h2o.performance(md, dx_test)

#### GBM with grid search ####

system.time({
  gbm <- h2o.grid("gbm", x = 2:ncol(dx_train) - 1, y = ncol(dx_train), 
                  training_frame = dx_train, validation_frame = dx_valid,
                  hyper_params = list(ntrees = c(50, 100, 250),
                                      max_depth = c(5, 10, 25),
                                      learn_rate = c(0.01, 0.1),
                                      nbins = c(50, 100, 250)),
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
  md <- h2o.deeplearning(x = 2:ncol(dx_train) - 1, y = ncol(dx_train), 
                         training_frame = dx_train, validation_frame = dx_valid,
                         activation = "Rectifier", hidden = c(200,200), epochs = 100,
                         stopping_rounds = 3, stopping_tolerance = 0)
})

md
h2o.auc(md)
h2o.auc(h2o.performance(md, dx_test))

#### Neural network with regularization (L1, L2, dropout) ####

system.time({
  md <- h2o.deeplearning(x = 2:ncol(dx_train) - 1, y = ncol(dx_train), 
                         training_frame = dx_train, validation_frame = dx_valid,
                         activation = "RectifierWithDropout", hidden = c(200,200), epochs = 100,
                         input_dropout_ratio = 0.2, hidden_dropout_ratios = c(0.2,0.2),
                         l1 = 1e-4, l2 = 1e-4,
                         stopping_rounds = 3, stopping_tolerance = 0)
})
md
h2o.auc(md)
h2o.auc(h2o.performance(md, dx_test))