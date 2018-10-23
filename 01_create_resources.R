library(AzureRMR)
library(AzureContainers)

# create resource group and resources ---

source("resource_specs.R")
deployresgrp <- az_rm$
    new(config_file="~/creds.json")$
    get_subscription(sub_id)$
    create_resource_group(rg_name, location=rg_loc)

deployresgrp$create_acr(acr_name)

deployresgrp$create_aks(aks_name,
    agent_pools=aks_pools("agentpool", num_nodes),
    enable_rbac=FALSE)
