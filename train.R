data(Boston, package="MASS")
install.packages("randomForest")
library(randomForest)

# train a model for median house price as a function of the other variables
model <- randomForest(medv ~ ., data=Boston, ntree=100)

# save the model
saveRDS(model, "model.rds")
