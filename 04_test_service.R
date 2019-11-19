source("resource_specs.R")


ingr_uri <- "http://52.156.169.134:8000/"

response <- httr::POST(paste0(ingr_uri, "score"),
    body=list(df=MASS::Boston[1:10, ]), encode="json")
httr::content(response, simplifyVector=TRUE)

