library(AzureRMR)
library(AzureContainers)

# create resource group and resources ---

source("resource_specs.R")
sub <- create_azure_login(config_file="creds.json")$
    get_subscription(sub_id)

deployresgrp <- (if(sub$resource_group_exists(rg_name))
    sub$get_resource_group(rg_name)
else sub$create_resource_group(rg_name, location=rg_loc))

deployresgrp$create_acr(acr_name)

# this will take several minutes (usually 10-20)
deployresgrp$create_aks(aks_name,
    agent_pools=aks_pools("agentpool", num_nodes),
    enable_rbac=FALSE)


