source("resource_specs.R")

ingr_uri_secure <- sprintf("https://%s.%s.cloudapp.azure.com/score", aks_name, rg_loc)

# check the cert is from Lets Encrypt
httr::BROWSE(ingr_uri_secure)

httr::content(
    httr::POST(
        ingr_uri_secure,
        httr::authenticate(username, password),
        body=list(df=MASS::Boston[1:10, ]),
        encode="json"
    ),
    simplifyVector=TRUE
)

