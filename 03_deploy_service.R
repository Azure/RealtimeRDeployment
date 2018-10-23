library(AzureRMR)
library(AzureContainers)

# run the following after resources have been created ---
source("resource_specs.R")
sub <- az_rm$
    new(config_file="creds.json")$
    get_subscription(sub_id)

deployresgrp <- sub$get_resource_group(rg_name)

# push image to registry
deployreg <- deployresgrp$
    get_acr(acr_name)$
    get_docker_registry()
deployreg$push("mls-model")

# create the deployment
deployclus <- deployresgrp$
    get_aks(aks_name)$
    get_cluster()


# create the deployment and service ---

# pass ACR auth details to AKS
deployclus$create_registry_secret(deployreg, "deploy-registry", email="email-here@example.com")

deployclus$create(gsub("registryname", acr_name, readLines("yaml/deployment.yaml")))
deployclus$create("yaml/service.yaml")


# check on deployment/service status
deployclus$get("deployment")
deployclus$get("service")
