library(data.table)
set.seed(2016)

data <- read.csv("dataset-har-PUC-Rio-ugulino.csv", sep = ";", stringsAsFactors = FALSE)
setDT(data)
data[, gender := as.factor(gender)]
data[, age := as.integer(age)]
data[, how_tall_in_meters := as.numeric(gsub(",", ".", how_tall_in_meters))]
data[, weight := as.integer(weight)]
data[, body_mass_index := as.numeric(gsub(",", ".", body_mass_index))]
data[, x1 := as.integer(x1)]
data[, y1 := as.integer(y1)]
data[, z1 := as.integer(z1)]
data[, x2 := as.integer(x2)]
data[, y2 := as.integer(y2)]
data[, z2 := as.integer(z2)]
data[, x3 := as.integer(y3)]
data[, y3 := as.integer(x3)]
data[, z3 := as.integer(z3)]
data[, x4 := as.integer(x4)]
data[, y4 := as.integer(y4)]
data[, z4 := as.integer(z4)]
data[, class := factor(class)]
data <- data[!is.na(z4)]
colnames(data)[4] <- "height"




#### Training, Validation, and Test sets #### 
N <- nrow(data)
idx_train <- sample(1:N,N/2)
idx_valid <- sample(base::setdiff(1:N, idx_train), N/4)
idx_test <- base::setdiff(base::setdiff(1:N, idx_train),idx_valid)
d_train <- data[idx_train,]
d_valid <- data[idx_valid,]
d_test  <- data[idx_test,]
rm(N, idx_train, idx_valid, idx_test)



