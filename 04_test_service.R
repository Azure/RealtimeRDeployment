source("resource_specs.R")

ingr_uri_secure <- sprintf("https://ml-model.%s.cloudapp.azure.com/score", rg_loc)
browseURL(ingr_uri_secure)

ingr_uri <- sprintf("http://ml-model.%s.cloudapp.azure.com/score", rg_loc)
httr::content(httr::POST(ingr_uri, body=list(df=MASS::Boston[1:10, ]), encode="json"), simplifyVector=TRUE)

