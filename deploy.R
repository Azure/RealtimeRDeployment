library(AzureRMR)
library(AzureContainers)

# authenticate with Azure
source("creds.R")
az <- AzureRMR::az_rm$new(tenant=tenant_id, app=app_id, secret=secret)

# create a resource group for the service
deployresgrp <- az$
    get_subscription(sub_id)$
    create_resource_group("deployresgrp", location="australiaeast")

# create ACR and AKS resources ---
deployreg_svc <- deployresgrp$
    create_acr("deployreg")

deployclus_svc <- deployresgrp$create_aks("deployclus",
    agent_pools=aks_pools("pool1", 2))


# run the following after resources have been created ---

# build the image
call_docker("build -t mls-model .")

# push image to registry
deployreg <- deployreg_svc$get_docker_registry()
deployreg$push("mls-model")

# create the deployment
deployclus <- deployclus_svc$get_cluster()
deployclus$create_registry_secret(deployreg, email="hongooi@microsoft.com")
deployclus$create("deploy.yaml")


# test service after deployment is complete ---

deployclus$get("service mls-model")

# obtain authentication token from service
response <- httr::POST("http://service-ip-address-here:12800/login/",
    body=list(username="admin", password="Microsoft@2018"),
    encode="json")
token <- httr::content(response)$access_token

# pass new dataset for scoring
newdata <- jsonlite::toJSON(list(inputData=MASS::Boston[1:10,]), dataframe="columns")

response <- httr::POST("http://service-ip-address-here:12800/api/mls-model/1.0.0",
    httr::add_headers(Authorization=paste0("Bearer ", token),
        `content-type`="application/json"),
    body=newdata)
httr::content(response, simplifyVector=TRUE)
