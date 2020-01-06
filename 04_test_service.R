source("resource_specs.R")

ingr_uri_secure <- sprintf("https://%s.%s.cloudapp.azure.com/score", aks_name, rg_loc)

# check the cert is from Lets Encrypt
httr::BROWSE(ingr_uri_secure)

# get some predicted values
res <- httr::POST(
    ingr_uri_secure,
    httr::authenticate(username, password),
    body=list(df=MASS::Boston[1:10, ]),
    encode="json"
)
httr::stop_for_status(res)

pred <- httr::content(res, simplifyVector=TRUE)
if(length(pred) != 10 || !is.numeric(pred))
    stop("Bad predictions")


