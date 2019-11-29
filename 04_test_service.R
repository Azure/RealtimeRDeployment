source("resource_specs.R")

ingr_uri_secure <- sprintf("https://ml-model.%s.cloudapp.azure.com/score", rg_loc)

# check the cert is from Lets Encrypt
browseURL(ingr_uri_secure)

httr::content(httr::POST(ingr_uri_secure, body=list(df=MASS::Boston[1:10, ]), encode="json"), simplifyVector=TRUE)

