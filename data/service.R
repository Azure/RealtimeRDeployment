library(RestRserve)
library(randomForest)

model <- readRDS("model.rds")

# scoring function: calls randomForest::predict on the provided dataset
# - input is a jsonified data frame, in the body of a PUT request
# - output is the predicted values
score <- function(request, response)
{
    df <- jsonlite::fromJSON(rawToChar(request$body), simplifyDataFrame=TRUE)
    sc <- predict(model, df)

    response$set_body(jsonlite::toJSON(sc, auto_unbox=TRUE))
    response$set_content_type("application/json")
}

app <- Application$new(middleware=list())
app$add_post(path="/score", FUN=score)

backend <- BackendRserve$new(app)
