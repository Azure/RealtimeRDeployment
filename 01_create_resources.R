library(AzureRMR)
library(AzureContainers)

# create resource group and resources ---

source("resource_specs.R")
deploysub <- az_rm$
    new(config_file="creds.json")$
    get_subscription(sub_id)

deployresgrp <- (if(deploysub$resource_group_exists(rg_name))
    deploysub$get_resource_group(rg_name)
else deploysub$create_resource_group(rg_name, location=rg_loc))

deployresgrp$create_acr(acr_name)

deployclus_svc <- deployresgrp$create_aks(aks_name,
    agent_pools=aks_pools("agentpool", num_nodes),
    enable_rbac=FALSE)

# check on the status of the deployment: repeat until deployment succeeds
deployclus_svc$sync_fields()

