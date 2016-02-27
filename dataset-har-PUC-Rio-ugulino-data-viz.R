library(data.table)
#### Summary of Users ####
user <- data[,.(Gender = max(gender), 
                Age = max(age), 
                Height = max(height), 
                Weight = max(weight), 
                BMI = max(body_mass_index),
                N = .N), 
             by = user]
setkey(user, user)

barplot.with.values <- function(values, names.arg, main) {
  names(values) <- names.arg
  bp <- barplot(values, main = main)
  mtext(side = 1, at = bp, text = values, line = 3)
}
summary(data$class)
barplot.with.values(summary(data$class), names(summary(data$class)), "Distribution of Classes")
summary(user)
barplot.with.values(user$N, user$user, "Distribution of Users")
par(mfrow=c(2,2))
barplot.with.values(user$Age, user$user, "Age")
barplot.with.values(user$Height, user$user, "Height")
barplot.with.values(user$Weight, user$user, "Wight")
barplot.with.values(user$BMI, user$user, "Body Mass Index")
par(mfrow=c(1,1))


#### Summary of Variables ####
class <- data[, .N, by = class]
setkey(class, class)
barplot.with.values(class$N, class$class, NULL)
library(scatterplot3d)
scatterplot3d(data$x1, data$y1, data$z1, main="Sensor 1")
scatterplot3d(data$x2, data$y2, data$z2, main="Sensor 2")
scatterplot3d(data$x3, data$y3, data$z3, main="Sensor 3")
scatterplot3d(data$x4, data$y4, data$z4, main="Sensor 4")


sensor_1 <- melt(data, id.vars = c("user", "class"), measure.vars = c("x1", "y1", "z1"))
sensor_2 <- melt(data, id.vars = c("user", "class"), measure.vars = c("x2", "y2", "z2"))
sensor_3 <- melt(data, id.vars = c("user", "class"), measure.vars = c("x3", "y3", "z3"))
sensor_4 <- melt(data, id.vars = c("user", "class"), measure.vars = c("x4", "y4", "z4"))
par(mfrow=c(1,5))
boxplot.sensor <- function(sensor, title) {
  for (c in class$class) {
    boxplot(value ~ variable, data = sensor[class == c], ylim = c(-300,300), main = c)
  }
  title(title, outer=TRUE)
}
boxplot.sensor(sensor_1, "Sensor 1")
boxplot.sensor(sensor_2, "Sensor 2")
boxplot.sensor(sensor_3, "Sensor 3")
boxplot.sensor(sensor_4, "Sensor 4")
par(mfrow=c(1,1))