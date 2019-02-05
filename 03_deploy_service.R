library(AzureRMR)
library(AzureContainers)

# resource/service objects
source("resource_specs.R")
deployresgrp <- az_rm$
    new(config_file="creds.json")$
    get_subscription(sub_id)$
    get_resource_group(rg_name)


### deploy predictive model as a service

# push image to registry
deployreg <- deployresgrp$
    get_acr(acr_name)$
    get_docker_registry()
deployreg$push("mls-model")


# create the deployment and service ---

deployclus_svc <- deployresgrp$get_aks(aks_name)

# use stable API version
deployclus_svc$.__enclos_env__$private$api_version <- "2018-03-31"

deployclus <- deployclus_svc$get_cluster()

# pass ACR auth details to AKS
deployclus$create_registry_secret(deployreg, "deploy-registry", email="email-here@example.com")

deployclus$create(gsub("registryname", acr_name, readLines("yaml/deployment.yaml")))
deployclus$create("yaml/service.yaml")


# check on deployment/service status: can take a few minutes
deployclus$get("deployment")
deployclus$get("service")

# display the dashboard
deployclus$show_dashboard()
