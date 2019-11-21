source("resource_specs.R")

ingr_uri <- "http://ml-model.australiaeast.cloudapp.azure.com/"

response <- httr::POST(paste0(ingr_uri, "score"), body=list(df=MASS::Boston[1:10, ]), encode="json")
httr::content(response, simplifyVector=TRUE)

