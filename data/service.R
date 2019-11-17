model <- readRDS("model.rds")
score <- function(inputData)
{
    require(randomForest)
    inputData <- as.data.frame(inputData)
    predict(model, inputData)
}

library(mrsdeploy)

password <- commandArgs(TRUE)[[1]]

remoteLogin("http://localhost:12800", username="admin", password=password, session=FALSE)
api <- publishService("mls-model", v="1.0.0",
    code=score,
    model=model,
    inputs=list(inputData="data.frame"),
    outputs=list(pred="vector"))
remoteLogout()
